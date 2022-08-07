import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/models/user.dart';
import 'package:connects_you/server/server.dart';

class Users {
  const Users();

  Future<Response<User>?> getUser(String userId) async {
    final userResponse =
        await Server.instance.get(endpoint: '${Endpoints.USERS}/$userId');
    if (userResponse.statusCode == StatusCodes.SUCCESS) {
      final body = userResponse.decodedBody as Map<String, dynamic>;
      if (body.containsKey('response') &&
          body['response'].containsKey('user')) {
        final user = body['response']['user'];
        return Response(
          code: body.get('code', userResponse.statusCode)!,
          message: body.get('message', '')!,
          response: User(
            userId: user.get('userId', '')!,
            email: user.get('email', '')!,
            name: user.get('name', '')!,
            photo: user.get('photo', '')!,
            publicKey: user.get('publicKey', '')!,
          ),
        );
      }
    }
    return null;
  }

  Future<Response<List<User>>?> getAllUsers(String token,
      [int pageSize = 10, int skip = 0]) async {
    final allUserResponse = await Server.instance
        .get(endpoint: Endpoints.USERS, headers: {'token': token});
    if (allUserResponse.statusCode == StatusCodes.SUCCESS) {
      final body = allUserResponse.decodedBody as Map<String, dynamic>;
      if (body.containsKey('response') &&
          body['response'].containsKey('users')) {
        final users = body['response']['users'] as List<Map<String, String>>;
        return Response(
          code: body.get('code', allUserResponse.statusCode)!,
          message: body.get('message', '')!,
          response: users
              .map((user) => User(
                    userId: user.get('userId', '')!,
                    email: user.get('email', '')!,
                    name: user.get('name', '')!,
                    photo: user.get('photo', '')!,
                    publicKey: user.get('publicKey', '')!,
                  ))
              .toList(),
        );
      }
    }
    return null;
  }
}
