import 'dart:convert';

import 'package:connects_you/config/google.dart';
import 'package:connects_you/constants/secureStorageKeys.dart';
import 'package:connects_you/data/models/authenticatedUser.dart';
import 'package:connects_you/data/models/sharedKey.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/helpers/secureStorage.dart';
import 'package:connects_you/logic/auth/auth_events.dart';
import 'package:connects_you/logic/auth/auth_states.dart';
import 'package:connects_you/repository/gDriveOps/gDriveOps.dart';
import 'package:connects_you/repository/localDB/DBOps.dart';
import 'package:connects_you/repository/localDB/sharedKeysOps.dart';
import 'package:connects_you/repository/localDB/userOps.dart';
import 'package:connects_you/repository/secureStorage/secureStorage.dart';
import 'package:connects_you/repository/server/auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cryptography/diffieHellman.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends Bloc<AuthEvents, AuthStates> {
  final AuthRepository authRepository;
  final UserOpsRepository userOpsRepository;
  final GDriveOpsRepository gDriveOpsRepository;
  final SharedKeysOpsRepository sharedKeysOpsRepository;
  final DBOpsRepository dbOpsRepository;
  final SecureStorageRepository secureStorageRepository;

  final _googleSignin = GoogleSignIn(
    serverClientId: GoogleConfig.clientId,
    scopes: GoogleConfig.scopes,
  );

  AuthBloc({
    required this.authRepository,
    required this.userOpsRepository,
    required this.gDriveOpsRepository,
    required this.sharedKeysOpsRepository,
    required this.dbOpsRepository,
    required this.secureStorageRepository,
  }) : super(const NotStartedAuthState()) {
    on<FetchAuthenticatedUser>(_fetchAuthenticatedUser);
    on<AuthenticateAuthEvent>(_authenticate);
    on<SignoutAuthEvent>(_signout);
  }

  Future _fetchAuthenticatedUser(FetchAuthenticatedUser _, Emitter emit) async {
    try {
      print("in progress");
      emit(const InProgressAuthState(
          authStateMessage: AuthStatesMessages.fetchingYourPrevSession));
      final authenticatedUser =
          await secureStorageRepository.fetchAuthenticatedUser();
      emit(CompletedAuthState(
          authStateMessage: AuthStatesMessages.sessionRetrieved,
          authenticatedUser: authenticatedUser));
    } catch (error) {
      debugPrint('$error');
      throw Exception('Fetch authenticated user Error');
    }
  }

  Future _onLogin(AuthenticatedServerUser user,
      {required String accessToken, required Emitter emit}) async {
    try {
      emit(const InProgressAuthState(
          authStateMessage: AuthStatesMessages.fetchingAndSavingYourPrevData));
      final userDriveResponse =
          await gDriveOpsRepository.getDriveUserData(user.userId);
      if (user.publicKey.isNotEmpty && userDriveResponse != null) {
        final privateKey = userDriveResponse['privateKey'];
        await userOpsRepository.insertLocalUsers([
          LocalDBUser(
            userId: user.userId,
            name: user.name,
            email: user.email,
            photo: user.photo,
            publicKey: user.publicKey,
            privateKey: privateKey,
          )
        ]);
        final authenticatedUser = AuthenticatedUser(
          userId: user.userId,
          name: user.name,
          email: user.email,
          photo: user.photo,
          publicKey: user.publicKey,
          privateKey: privateKey,
          token: user.token,
        );
        await SecureStorage.instance.write(
          key: SecureStorageKeys.AUTH_USER,
          value: jsonEncode({'token': user.token, 'userId': user.userId}),
        );
        final driveSharedKeys = await gDriveOpsRepository
            .getDriveSharedKeys(true) as List<SharedKey>?;
        if (driveSharedKeys != null && driveSharedKeys.isNotEmpty) {
          emit(const InProgressAuthState(
              authStateMessage: AuthStatesMessages.savingLocalKeys));
          await sharedKeysOpsRepository.insertSharedKeys(driveSharedKeys);
        }
        emit(CompletedAuthState(
            authStateMessage: AuthStatesMessages.authCompleted,
            authenticatedUser: authenticatedUser));
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
    required Emitter emit,
  }) async {
    try {
      emit(const InProgressAuthState(
          authStateMessage: AuthStatesMessages.savingYourDetails));
      await userOpsRepository.insertLocalUsers([
        LocalDBUser(
          userId: user.userId,
          name: user.name,
          email: user.email,
          photo: user.photo,
          publicKey: publicKey,
          privateKey: privateKey,
        )
      ]);
      emit(const InProgressAuthState(
          authStateMessage: AuthStatesMessages.savingDriveKeys));
      await gDriveOpsRepository.saveUserKeys(
        userId: user.userId,
        privateKey: privateKey,
        publicKey: publicKey,
      );
      final authenticatedUser = AuthenticatedUser(
        userId: user.userId,
        name: user.name,
        email: user.email,
        photo: user.photo,
        publicKey: publicKey,
        privateKey: privateKey,
        token: user.token,
      );
      await SecureStorage.instance.write(
        key: SecureStorageKeys.AUTH_USER,
        value: jsonEncode({'token': user.token, 'userId': user.userId}),
      );
      emit(CompletedAuthState(
          authStateMessage: AuthStatesMessages.authCompleted,
          authenticatedUser: authenticatedUser));
    } catch (error) {
      debugPrint('$error');
      throw Exception('Signup Error');
    }
  }

  Future _authenticate(AuthenticateAuthEvent _, Emitter emit) async {
    try {
      emit(const StartedAuthState());
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
          final serverAuthUser = await authRepository.authenticate(
            token: authToken.idToken!,
            publicKey: publicKey,
            fcmToken: fcmToken,
          );

          if (serverAuthUser != null) {
            if (serverAuthUser.response.method == AuthMethod.login) {
              emit(const InProgressAuthState(
                  authStateMessage: AuthStatesMessages.authenticatingYou));
              await _onLogin(serverAuthUser.response,
                  accessToken: authToken.accessToken!, emit: emit);
            } else if (serverAuthUser.response.method == AuthMethod.signup) {
              emit(const InProgressAuthState(
                  authStateMessage: AuthStatesMessages.creatingYourAccount));
              await _onSignup(serverAuthUser.response,
                  accessToken: authToken.accessToken!,
                  publicKey: publicKey,
                  privateKey: privateKey,
                  emit: emit);
            }
          } else {
            throw Exception('Server user is null');
          }
        }
        throw Exception(
            '(privateKey != null && publicKey != null && authToken.idToken != null && authToken.accessToken != null && fcmToken != null) is false');
      } else {
        throw Exception('Google auth user is null');
      }
    } catch (error) {
      debugPrint(error.toString());
      emit(const CompletedAuthState(
          authStateMessage: AuthStatesMessages.authError));

      await dbOpsRepository.deleteDB();
      await SecureStorage.instance.deleteAll();
      rethrow;
    }
  }

  Future<bool?> _signout(SignoutAuthEvent eventData, Emitter emit) async {
    final signoutResponse =
        await authRepository.signout(token: eventData.token);
    emit(const NotStartedAuthState());
    await dbOpsRepository.deleteDB();
    await SecureStorage.instance.deleteAll();
    _googleSignin.signOut();
    if (signoutResponse != null) return signoutResponse.response;
    return null;
  }
}
