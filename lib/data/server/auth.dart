import 'dart:convert';

import 'package:connects_you/config/google.dart';
import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_wrapper/http.dart';

class AuthDataSource {
  const AuthDataSource._();
  static const _instance = AuthDataSource._();
  static const instance = _instance;

  Future<DecodedResponse?> authenticate({
    required String token,
    required String publicKey,
    required String fcmToken,
  }) async {
    final authResponse = await Server.instance.post(
      endpoint: Endpoints.AUTHENTICATE,
      body: json.encode({
        'token': token,
        'publicKey': publicKey,
        'fcmToken': fcmToken,
      }),
    );
    if (authResponse.statusCode == StatusCodes.SUCCESS) {
      return authResponse;
    }
    throw Exception({"statusCode": authResponse.statusCode});
  }

  Future<DecodedResponse?> signout({required String token}) async {
    final signoutResponse = await Server.instance
        .patch(endpoint: Endpoints.SIGNOUT, headers: {'token': token});
    if ([StatusCodes.SUCCESS, StatusCodes.NO_UPDATE]
        .contains(signoutResponse.statusCode)) {
      return signoutResponse;
    }
    throw Exception({"statusCode": signoutResponse.statusCode});
  }

  Future<DecodedResponse?> refreshToken({required String token}) async {
    final refreshTokenResponse = await Server.instance
        .patch(endpoint: Endpoints.REFRESH_TOKEN, headers: {'token': token});
    if (refreshTokenResponse.statusCode == StatusCodes.SUCCESS) {
      return refreshTokenResponse;
    }
    throw Exception({"statusCode": refreshTokenResponse.statusCode});
  }

  Future<GoogleSignInAuthentication> refreshGoogleTokens() async {
    final googleSignin = GoogleSignIn(
      serverClientId: GoogleConfig.clientId,
      scopes: GoogleConfig.scopes,
    );

    final user = await googleSignin.signInSilently();
    if (user != null) {
      return await user.authentication;
    } else {
      throw Exception('signin silently but user null');
    }
  }
}
