import 'package:connects_you/data/models/room.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/data/server/details.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:flutter/rendering.dart';

class DetailsRepository {
  const DetailsRepository();
  final DetailsDataSource detailsDataSource = DetailsDataSource.instance;

  Future<Response<Room>?> getRoom(String roomId) async {
    try {
      final detailResponse = await detailsDataSource.getRoom(roomId);
      final body = detailResponse != null
          ? detailResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null &&
          body.containsKey('response') &&
          body['response'].containsKey('room')) {
        final room = body['response']['room'];
        return Response(
          code: body.get('code', detailResponse!.statusCode)!,
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
      throw Exception('no response');
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<User>?> getUser(String userId) async {
    try {
      final userResponse = await detailsDataSource.getUser(userId);
      final body = userResponse != null
          ? userResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null &&
          body.containsKey('response') &&
          body['response'].containsKey('user')) {
        final user = body['response']['user'];
        return Response(
          code: body.get('code', userResponse!.statusCode)!,
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
      throw Exception('no response');
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<List<User>>?> getAllUsers(String token,
      [int pageSize = 10, int skip = 0]) async {
    try {
      final allUserResponse = await detailsDataSource.getAllUsers(token);
      final body = allUserResponse != null
          ? allUserResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null &&
          body.containsKey('response') &&
          body['response'].containsKey('user')) {
        final response = body.get('response') as Map<String, dynamic>?;
        final users = response?.get('users') as List<dynamic>?;
        if (users != null) {
          return Response(
            code: body.get('code', allUserResponse!.statusCode)!,
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
        } else {
          return Response(
              code: body.get('code', allUserResponse!.statusCode)!,
              message: body.get('message', '')!,
              response: []);
        }
      }
      throw Exception('no response');
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
