import 'package:connects_you/data/models/authenticatedUser.dart';
import 'package:connects_you/data/server/auth.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:flutter/rendering.dart';

class AuthRepository {
  const AuthRepository();
  final AuthDataSource authDataSource = AuthDataSource.instance;

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
      final body = authResponse != null
          ? authResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null &&
          body.containsKey('response') &&
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
          code: body.get('code', authResponse!.statusCode)!,
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
      throw Exception("No response");
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<bool>?> signout({required String token}) async {
    try {
      final signoutResponse = await authDataSource.signout(token: token);
      final body = signoutResponse != null
          ? signoutResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null) {
        return Response(
          code: body.get('code', signoutResponse!.statusCode)!,
          message: body.get('message', '')!,
          response: true,
        );
      }
      throw Exception('no Response');
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<String>?> refreshToken({required String token}) async {
    try {
      final refreshTokenResponse =
          await authDataSource.refreshToken(token: token);
      final body = refreshTokenResponse != null
          ? refreshTokenResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null &&
          body.containsKey('response') &&
          body['response'].containsKey('token')) {
        return Response(
          code: body.get('code', refreshTokenResponse!.statusCode),
          message: body.get('message', '')!,
          response: body['response']['token'],
        );
      }
      throw Exception("no response");
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
