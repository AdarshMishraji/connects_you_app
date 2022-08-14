import 'dart:async';
import 'dart:convert';

import 'package:connects_you/config/google.dart';
import 'package:connects_you/constants/encryptedStorageKeys.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/gDriveOps/gDriveOps.dart';
import 'package:connects_you/helpers/CustomException.dart';
import 'package:connects_you/helpers/secureStorage.dart';
import 'package:connects_you/localDB/DBProvider.dart';
import 'package:connects_you/localDB/localDBOps.dart';
import 'package:connects_you/models/sharedKey.dart';
import 'package:connects_you/models/user.dart';
import 'package:connects_you/providers/socket.dart';
import 'package:connects_you/server/responses/authenticatedUser.dart';
import 'package:connects_you/server/server.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cryptography/diffieHellman.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthStatesMessages {
  static const String fetchingYourPrevSession =
      'Fetching Your Previous Session';
  static const String sessionRetrieved = 'Session Retrieved';
  static const String sessionNotRetrieved =
      'Session Not Retrieved\nKindly authenticate yourself';
  static const String authenticatingYou = 'Authenticating You';
  static const String savingYourDetails =
      '$creatingYourAccount${'\n'}Saving Your Details';
  static const String savingLocalKeys = '$authenticatingYou${'\n'}Saving Keys';
  static const String creatingYourAccount = 'Creating Your Account';
  static const String savingDriveKeys =
      '$creatingYourAccount${'\n'}Saving Keys';
  static const String fetchingAndSavingYourPrevData =
      '$authenticatingYou${'\n'}Fetching And Saving Your Previous Data';
  static const String authCompleted = 'Authentication Process Completed';
  static const String authError = 'Authentication Process Failed';
}

enum AuthStates { notStarted, inProgress, completed }

class Auth with ChangeNotifier {
  AuthenticatedUser? authenticatedUser;
  String? authStateMessage;
  AuthStates authState = AuthStates.notStarted;

  final _googleSignin = GoogleSignIn(
    serverClientId: GoogleConfig.clientId,
    scopes: GoogleConfig.scopes,
  );

  Future<bool> fetchAndSetAuthUser() async {
    try {
      authStateMessage = AuthStatesMessages.fetchingYourPrevSession;
      notifyListeners();
      final authUserString = await SecureStorage.instance
          .read(key: EncryptedStorageKeys.AUTH_USER);
      print(authUserString);
      if (authUserString != null) {
        final Map<String, dynamic> authUserTokenUserId =
            jsonDecode(authUserString);
        final authUser = await LocalDBOps.userOps
            .fetchLocalUserWithUserId(authUserTokenUserId['userId']);
        if (authUser != null && authUser.privateKey != null) {
          authenticatedUser = AuthenticatedUser(
            userId: authUser.userId,
            name: authUser.name,
            email: authUser.email,
            photo: authUser.photo,
            publicKey: authUser.publicKey,
            privateKey: authUser.privateKey!,
            token: authUserTokenUserId.get('token', ''),
          );
          SocketOps(authenticatedUser!.token);
          authStateMessage = AuthStatesMessages.sessionRetrieved;
          notifyListeners();
          return true;
        }
      }
      throw Exception('no auth session found');
    } catch (error) {
      print(error);
      authStateMessage = AuthStatesMessages.sessionNotRetrieved;
      notifyListeners();
      await DBProvider.deleteDB();
      await SecureStorage.instance.deleteAll();
      return false;
    }
  }

  bool get isAuthenticated {
    return authenticatedUser?.token != null;
  }

  Future _onLogin(AuthenticatedServerUser user,
      {required String accessToken}) async {
    try {
      authStateMessage = AuthStatesMessages.fetchingAndSavingYourPrevData;
      notifyListeners();
      final userDriveResponse = await GDriveOps.getDriveUserData(user.userId);
      if (user.publicKey.isNotEmpty && userDriveResponse != null) {
        final privateKey = userDriveResponse['privateKey'];
        await LocalDBOps.userOps.insertLocalUsers([
          LocalDBUser(
            userId: user.userId,
            name: user.name,
            email: user.email,
            photo: user.photo,
            publicKey: user.publicKey,
            privateKey: privateKey,
          )
        ]);
        authenticatedUser = AuthenticatedUser(
          userId: user.userId,
          name: user.name,
          email: user.email,
          photo: user.photo,
          publicKey: user.publicKey,
          privateKey: privateKey,
          token: user.token,
        );
        await SecureStorage.instance.write(
          key: EncryptedStorageKeys.AUTH_USER,
          value: jsonEncode({'token': user.token, 'userId': user.userId}),
        );
        final driveSharedKeys =
            await GDriveOps.getDriveSharedKeys(true) as List<SharedKey>?;
        if (driveSharedKeys != null && driveSharedKeys.isNotEmpty) {
          authStateMessage = AuthStatesMessages.savingLocalKeys;
          notifyListeners();
          await LocalDBOps.sharedKeysOps.insertSharedKeys(driveSharedKeys);
        }
        return;
      }
      throw Exception('Login Error');
    } catch (error) {
      debugPrint('$error');
      throw Exception('Login Error');
    }
  }

  Future _onSignup(
    AuthenticatedServerUser user, {
    required String accessToken,
    required String publicKey,
    required String privateKey,
  }) async {
    try {
      authStateMessage = AuthStatesMessages.savingYourDetails;
      notifyListeners();
      await LocalDBOps.userOps.insertLocalUsers([
        LocalDBUser(
          userId: user.userId,
          name: user.name,
          email: user.email,
          photo: user.photo,
          publicKey: publicKey,
          privateKey: privateKey,
        )
      ]);
      authStateMessage = AuthStatesMessages.savingDriveKeys;
      notifyListeners();
      await GDriveOps.saveUserKeys(
        userId: user.userId,
        privateKey: privateKey,
        publicKey: publicKey,
      );
      authenticatedUser = AuthenticatedUser(
        userId: user.userId,
        name: user.name,
        email: user.email,
        photo: user.photo,
        publicKey: publicKey,
        privateKey: privateKey,
        token: user.token,
      );
      await SecureStorage.instance.write(
        key: EncryptedStorageKeys.AUTH_USER,
        value: jsonEncode({'token': user.token, 'userId': user.userId}),
      );
      return;
    } catch (error) {
      debugPrint('$error');
      throw Exception('Signup Error');
    }
  }

  Future<AuthenticatedServerUser> authenticate() async {
    try {
      authState = AuthStates.inProgress;
      notifyListeners();
      final user = await _googleSignin.signIn();
      if (user != null) {
        final authToken = await user.authentication;
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final dh = DiffieHellman.instance;
        await dh.generateKeyPair();
        final String? privateKey = dh.alicePrivateKey;
        final String? publicKey = dh.alicePublicKey;
        if (privateKey != null &&
            publicKey != null &&
            authToken.idToken != null &&
            authToken.accessToken != null &&
            fcmToken != null) {
          final serverAuthUser = await Server.AuthOps.authenticate(
            token: authToken.idToken!,
            publicKey: publicKey,
            fcmToken: fcmToken,
          );

          if (serverAuthUser != null) {
            if (serverAuthUser.response.method == AuthMethod.login) {
              authStateMessage = AuthStatesMessages.authenticatingYou;
              notifyListeners();
              await _onLogin(
                serverAuthUser.response,
                accessToken: authToken.accessToken!,
              );
            } else if (serverAuthUser.response.method == AuthMethod.signup) {
              authStateMessage = AuthStatesMessages.creatingYourAccount;
              notifyListeners();
              await _onSignup(serverAuthUser.response,
                  accessToken: authToken.accessToken!,
                  publicKey: publicKey,
                  privateKey: privateKey);
            }
            authStateMessage = AuthStatesMessages.authCompleted;
            authState = AuthStates.completed;
            notifyListeners();
            return serverAuthUser.response;
          } else {
            throw const CustomException(errorMessage: 'Server user is null');
          }
        }
        throw const CustomException(
            errorMessage:
                '(privateKey != null && publicKey != null && authToken.idToken != null && authToken.accessToken != null && fcmToken != null) is false');
      } else {
        throw const CustomException(errorMessage: 'Google auth user is null');
      }
    } catch (error) {
      debugPrint(error.toString());
      authStateMessage = AuthStatesMessages.authError;
      authState = AuthStates.completed;
      notifyListeners();
      await DBProvider.deleteDB();
      await SecureStorage.instance.deleteAll();
      rethrow;
    }
  }

  Future<bool?> signout() async {
    if (authenticatedUser != null) {
      final signoutResponse =
          await Server.AuthOps.signout(token: authenticatedUser!.token);
      authenticatedUser = null;
      notifyListeners();
      await DBProvider.deleteDB();
      await SecureStorage.instance.deleteAll();
      _googleSignin.signOut();
      if (signoutResponse != null) return signoutResponse.response;
    }
    return null;
  }

  Future<GoogleSignInAuthentication> refreshGoogleTokens() async {
    final user = await _googleSignin.signInSilently();
    if (user != null) {
      return await user.authentication;
    } else {
      throw Exception('signin silently but user null');
    }
  }
}
