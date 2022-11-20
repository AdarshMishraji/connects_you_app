import 'dart:convert';

import 'package:connects_you/config/google.dart';
import 'package:connects_you/constants/response_status.dart';
import 'package:connects_you/data/server/endpoints.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_wrapper/http.dart';

class AuthDataSource {
  const AuthDataSource._();
  static const _instance = AuthDataSource._();

  factory AuthDataSource() {
    return _instance;
  }

  Future<DecodedResponse?> authenticate({
    required String token,
    required String publicKey,
    required String fcmToken,
  }) async {
    final authResponse = await Server().post(
        endpoint: Endpoints.authenticate,
        body: json.encode({
          'token': token,
          'publicKey': publicKey,
          'fcmToken': fcmToken,
        }));
    if (authResponse.statusCode == StatusCodes.SUCCESS) {
      return authResponse;
    }
    throw Exception({"statusCode": authResponse.statusCode});
  }

  Future<DecodedResponse?> signout({required String token}) async {
    final signoutResponse = await Server()
        .post(endpoint: Endpoints.signout, headers: {'token': token});
    if ([StatusCodes.SUCCESS, StatusCodes.NO_UPDATE]
        .contains(signoutResponse.statusCode)) {
      return signoutResponse;
    }
    throw Exception({"statusCode": signoutResponse.statusCode});
  }

  Future<DecodedResponse?> refreshToken({required String token}) async {
    final refreshTokenResponse = await Server()
        .post(endpoint: Endpoints.refreshToken, headers: {'token': token});
    if (refreshTokenResponse.statusCode == StatusCodes.SUCCESS) {
      return refreshTokenResponse;
    }
    throw Exception({"statusCode": refreshTokenResponse.statusCode});
  }

  Future<DecodedResponse?> updateFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final updateFcmTokenResponse = await Server().put(
      endpoint: Endpoints.updateFcmToken,
      headers: {'token': token},
      body: json.encode({'fcmToken': fcmToken}),
    );
    if (updateFcmTokenResponse.statusCode == StatusCodes.SUCCESS) {
      return updateFcmTokenResponse;
    }
    throw Exception({"statusCode": updateFcmTokenResponse.statusCode});
  }

  Future<DecodedResponse?> getCurrentLoginInfo({
    required String token,
  }) async {
    final getCurrentLoginInfoResponse = await Server().get(
      endpoint: Endpoints.currentLoginInfo,
      headers: {'token': token},
    );
    if (getCurrentLoginInfoResponse.statusCode == StatusCodes.SUCCESS) {
      return getCurrentLoginInfoResponse;
    }
    throw Exception({"statusCode": getCurrentLoginInfoResponse.statusCode});
  }

  Future<DecodedResponse?> getLoginHistory({
    required String token,
  }) async {
    final getLoginHistoryResponse = await Server().get(
      endpoint: Endpoints.myLoginHistory,
      headers: {'token': token},
    );
    if (getLoginHistoryResponse.statusCode == StatusCodes.SUCCESS) {
      return getLoginHistoryResponse;
    }
    throw Exception({"statusCode": getLoginHistoryResponse.statusCode});
  }

  Future<GoogleSignInAuthentication> refreshGoogleTokens() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: GoogleConfig.clientId,
      scopes: GoogleConfig.scopes,
    );

    final user = await googleSignIn.signInSilently();
    if (user != null) {
      return await user.authentication;
    } else {
      throw Exception('signin silently but user null');
    }
  }
}
