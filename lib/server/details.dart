import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/models/room.dart';
import 'package:connects_you/models/user.dart';
import 'package:connects_you/server/server.dart';

class Details {
  const Details();

  Future<Response<Room>?> getRoom(String roomId) async {
    final detailResponse =
        await Server.instance.get(endpoint: '${Endpoints.ROOMS}/$roomId');
    if (detailResponse.statusCode == StatusCodes.SUCCESS) {
      final body = detailResponse.decodedBody as Map<String, dynamic>;
      if (body.containsKey('response') &&
          body['response'].containsKey('room')) {
        final room = body['response']['room'];
        return Response(
          code: body.get('code', detailResponse.statusCode)!,
          message: body.get('message', '')!,
          response: Room(
            roomId: room.get('roomId', '')!,
            roomLogo: room.get('roomLogo', '')!,
            roomName: room.get('roomName', '')!,
            roomDescription: room.get('roomDescription', '')!,
            roomType: room.get('roomType', '')!,
            createdByUserId: room.get('createdByUserId', '')!,
            createdAt: room.get('createdAt', '')!,
            updatedAt: room.get('updatedAt', '')!,
          ),
        );
      }
    }
    return null;
  }

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
      final response = body.get('response') as Map<String, dynamic>?;
      final users = response?.get('users') as List<dynamic>?;
      if (users != null) {
        return Response(
          code: body.get('code', allUserResponse.statusCode)!,
          message: body.get('message', '')!,
          response: users.map((user) {
            user = user as Map<String, dynamic>;
            return User(
              userId: user.get('userId', '')!,
              email: user.get('email', '')!,
              name: user.get('name', '')!,
              photo: user.get('photo', '')!,
              publicKey: user.get('publicKey', '')!,
            );
          }).toList(),
        );
      }
    }
    return null;
  }
}
