import 'package:connects_you/data/models/cachedData.dart';
import 'package:connects_you/data/models/room.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/data/server/me.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:flutter/rendering.dart';

class MeRepository {
  const MeRepository();
  final MeDataSource meDataSource = MeDataSource.instance;

  Future<Response<User>?> getAuthUser(String token) async {
    try {
      final authUserResponse = await meDataSource.getAuthUser(token);
      final body = authUserResponse != null
          ? authUserResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null &&
          body.containsKey('response') &&
          body['response'].containsKey('user')) {
        final user = body['response']['user'];
        return Response(
          code: body.get('code', authUserResponse!.statusCode)!,
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

  // TODO create cached_data (partially completed already for rooms)
  Future<Response<CachedData>?> getCachedData(String token,
      [bool shouldSaveToLocalDB = true]) async {
    try {
      final cachedDataResponse = await meDataSource.getCachedData(token);
      final body = cachedDataResponse != null
          ? cachedDataResponse.decodedBody as Map<String, dynamic>
          : null;
      if (body != null && body.containsKey('response')) {
        final dataToSend = {};
        final response = body['response'] as Map<String, dynamic>;
        if (response.containsKey('roomsData')) {
          final roomsData = response['roomsData'] as Map<String, dynamic>;
          if (roomsData.containsKey('rooms')) {
            final rooms = roomsData['rooms'] as List<Map<String, dynamic>>;
            dataToSend['roomsData']['rooms'] = rooms.map((room) => Room(
                  roomId: room.get('roomId', '')!,
                  roomName: room.get('roomName', '')!,
                  roomLogo: room.get('roomLogo', '')!,
                  roomDescription: room.get('roomDescription', '')!,
                  roomType: room.get('roomType', '')!,
                  createdByUserId: room.get('createdByUserId', '')!,
                  createdAt: room.get('createdAt', '')!,
                  updatedAt: room.get('updatedAt', '')!,
                ));
          }
          if (roomsData.containsKey('roomUsers')) {
            dataToSend['roomsData']['rooms'] = null;
          }
        }
        if (response.containsKey('messages')) {
          dataToSend['messages'] = null;
        }
        if (response.containsKey('notifications')) {
          dataToSend['notifications'] = null;
        }
        if (response.containsKey('encryptedStrings')) {
          dataToSend['encryptedStrings'] = null;
        }
        return Response<CachedData>(
          code: body.get('code', cachedDataResponse!.statusCode)!,
          message: body.get('messages', ''),
          response: CachedData(
            roomData: dataToSend.get('roomsData'),
            messages: dataToSend.get('messages'),
            notifications: dataToSend.get('notifications'),
            encryptedStrings: dataToSend.get('encryptedStrings'),
          ),
        );
      }
      throw Exception('no response');
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
