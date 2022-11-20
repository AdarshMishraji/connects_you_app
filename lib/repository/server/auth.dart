import 'dart:developer';

import 'package:connects_you/data/models/authenticated_user.dart';
import 'package:connects_you/data/models/login_history.dart';
import 'package:connects_you/data/server/auth.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:connects_you/constants/auth_constants.dart';
import 'package:connects_you/repository/server/_helper.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository _instance = AuthRepository._();

  factory AuthRepository() {
    return _instance;
  }

  final AuthDataSource authDataSource = AuthDataSource();

  Future<Response<AuthenticatedServerUser>?> authenticate({
    required String token,
    required String publicKey,
    required String fcmToken,
  }) async {
    try {
      final authResponse = await authDataSource.authenticate(
        token: token,
        publicKey: publicKey,
        fcmToken: fcmToken,
      );
      inspect(authResponse);
      final response = getDecodedDataFromResponse(authResponse);

      final Map<String, dynamic> authenticatedUser =
          response.data.get('user') ?? <String, dynamic>{};

      final String methodString = response.data.get('method', '');
      final String method = methodString == AuthMethod.LOGIN
          ? AuthMethod.LOGIN
          : methodString == AuthMethod.SIGNUP
              ? AuthMethod.SIGNUP
              : AuthMethod.NONE;

      if (isEmptyEntity(authenticatedUser) || method == AuthMethod.NONE) {
        throw Exception("No response");
      }

      return Response<AuthenticatedServerUser>(
        code: authResponse?.statusCode ?? 200,
        status: response.status,
        response: AuthenticatedServerUser(
          method: method,
          userId: authenticatedUser.get('userId', '')!,
          name: authenticatedUser.get('name', '')!,
          email: authenticatedUser.get('email', '')!,
          photoUrl: authenticatedUser.get('photoUrl', '')!,
          publicKey: authenticatedUser.get('publicKey', '')!,
          token: authenticatedUser.get('token', '')!,
        ),
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<bool>?> signout({required String token}) async {
    try {
      final signoutResponse = await authDataSource.signout(token: token);
      final response = getDecodedDataFromResponse(signoutResponse);

      return Response(
        code: signoutResponse?.statusCode ?? 200,
        status: response.status,
        response: true,
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<String>?> refreshToken({required String token}) async {
    try {
      final refreshTokenResponse =
          await authDataSource.refreshToken(token: token);

      final response = getDecodedDataFromResponse(refreshTokenResponse);

      final String newToken = response.data.get('token', '');

      if (isEmptyEntity(newToken)) throw Exception("No response");

      return Response(
        code: refreshTokenResponse?.statusCode ?? 200,
        status: response.status,
        response: newToken,
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<bool>?> updateFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    try {
      final refreshTokenResponse =
          await authDataSource.updateFcmToken(token: token, fcmToken: fcmToken);

      final response = getDecodedDataFromResponse(refreshTokenResponse);

      return Response(
        code: refreshTokenResponse?.statusCode ?? 200,
        status: response.status,
        response: true,
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  UserLoginInfo _getUserLoginInfoResponse(Map<String, dynamic> loginInfo) {
    return UserLoginInfo(
      userId: loginInfo.get('userId', '')!,
      loginId: loginInfo.get('loginId', '')!,
      isValid: loginInfo.get('isValid', false)!,
      createdAt: loginInfo.get('createdAt', '')!,
      loginMetaData: ClientMetaData(
        ip: loginInfo.get('ip', '')!,
        userAgent: loginInfo.get('userAgent', '')!,
        geoData: GeoData(
          status: loginInfo.get('status', '')!,
          message: loginInfo.get('message', '')!,
          continent: loginInfo.get('continent', '')!,
          continentCodes: loginInfo.get('continentCodes', '')!,
          country: loginInfo.get('country', '')!,
          countryCode: loginInfo.get('countryCode', '')!,
          region: loginInfo.get('region', '')!,
          regionName: loginInfo.get('regionName', '')!,
          city: loginInfo.get('city', '')!,
          zip: loginInfo.get('zip', '')!,
          lat: loginInfo.get('lat', '')!,
          lon: loginInfo.get('lon', '')!,
          timezone: loginInfo.get('timezone', '')!,
          offset: loginInfo.get('offset', '')!,
          currency: loginInfo.get('currency', '')!,
          isp: loginInfo.get('isp', '')!,
          org: loginInfo.get('org', '')!,
          as: loginInfo.get('as', '')!,
          asname: loginInfo.get('asname', '')!,
          reverse: loginInfo.get('reverse', '')!,
          mobile: loginInfo.get('mobile', '')!,
          proxy: loginInfo.get('proxy', '')!,
          hosting: loginInfo.get('hosting', '')!,
          query: loginInfo.get('query', '')!,
        ),
      ),
    );
  }

  Future<Response<UserLoginInfo>?> getCurrentLoginInfo({
    required String token,
  }) async {
    try {
      final currentLoginInfoResponse =
          await authDataSource.getCurrentLoginInfo(token: token);

      final response = getDecodedDataFromResponse(currentLoginInfoResponse);

      final Map<String, dynamic> loginInfo =
          response.data.get('userLoginInfo') ?? <String, dynamic>{};

      if (isEmptyEntity(loginInfo)) throw Exception("No response");

      return Response(
          code: currentLoginInfoResponse?.statusCode ?? 200,
          status: response.status,
          response: _getUserLoginInfoResponse(loginInfo));
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<List<UserLoginInfo>?>?> getLoginHistory({
    required String token,
  }) async {
    try {
      final loginHistoryResponse =
          await authDataSource.getLoginHistory(token: token);

      final response = getDecodedDataFromResponse(loginHistoryResponse);

      final List<Map<String, dynamic>> loginHistoryList =
          response.data.get('userLoginHistory') ?? <Map<String, dynamic>>[];

      if (isEmptyEntity(loginHistoryList)) throw Exception("No response");

      final List<UserLoginInfo> loginHistory = loginHistoryList
          .map((loginInfo) => _getUserLoginInfoResponse(loginInfo))
          .toList();

      return Response(
        code: loginHistoryResponse?.statusCode ?? 200,
        status: response.status,
        response: loginHistory,
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
