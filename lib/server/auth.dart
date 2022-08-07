import 'dart:convert';

import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/server/responses/authenticatedUser.dart';
import 'package:connects_you/server/server.dart';

class Auth {
  const Auth();

  Future<Response<AuthenticatedServerUser>?> authenticate({
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
      final body = authResponse.decodedBody as Map<String, dynamic>;
      if (body.containsKey('response') &&
          body['response'].containsKey('user') &&
          body['response'].containsKey('method')) {
        final Map<String, dynamic> response = body['response'];
        final Map<String, dynamic> authenticatedUser = response['user'];
        final AuthMethod method =
            response.get('method', '') == AuthMethod.login.value
                ? AuthMethod.login
                : response.get('method', '') == AuthMethod.signup.value
                    ? AuthMethod.signup
                    : AuthMethod.none;
        return Response<AuthenticatedServerUser>(
          code: body.get('code', authResponse.statusCode)!,
          message: body.get('message', '')!,
          response: AuthenticatedServerUser(
            method: method,
            userId: authenticatedUser.get('userId', '')!,
            name: authenticatedUser.get('name', '')!,
            email: authenticatedUser.get('email', '')!,
            photo: authenticatedUser.get('photo', '')!,
            publicKey: authenticatedUser.get('publicKey', '')!,
            token: authenticatedUser.get('token', '')!,
          ),
        );
      }
    }
    return null;
  }

  Future<Response<bool>?> signout({required String token}) async {
    final signoutResponse = await Server.instance
        .patch(endpoint: Endpoints.SIGNOUT, headers: {'token': token});
    if ([StatusCodes.SUCCESS, StatusCodes.NO_UPDATE]
        .contains(signoutResponse.statusCode)) {
      final body = signoutResponse.decodedBody as Map<String, dynamic>;
      return Response(
        code: body.get('code', signoutResponse.statusCode)!,
        message: body.get('message', '')!,
        response: true,
      );
    }
    return null;
  }

  Future<Response<String>?> refreshToken({required String token}) async {
    final refreshTokenResponse = await Server.instance
        .patch(endpoint: Endpoints.REFRESH_TOKEN, headers: {'token': token});
    if (refreshTokenResponse.statusCode == StatusCodes.SUCCESS) {
      final body = refreshTokenResponse.decodedBody as Map<String, dynamic>;
      if (body.containsKey('response') &&
          body['response'].containsKey('token')) {
        return Response(
          code: body.get('code', refreshTokenResponse.statusCode),
          message: body.get('message', '')!,
          response: body['response']['token'],
        );
      }
    }
    return null;
  }
}
