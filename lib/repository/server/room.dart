import 'package:connects_you/data/models/room.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/data/server/auth.dart';
import 'package:connects_you/data/server/room.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:connects_you/data/server/user.dart';
import 'package:connects_you/repository/server/_helper.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class RoomRepository {
  RoomRepository._();

  static final RoomRepository _instance = RoomRepository._();

  factory RoomRepository() {
    return _instance;
  }

  final RoomDataSource roomDataSource = RoomDataSource();

  Future<Response<List<Room>>?> getAllRooms({
    required String token,
    int limit = 10,
    int offset = 0,
    bool onlyDuets = false,
    bool onlyGroups = false,
    bool requiredDetailedRoomUserData = true,
  }) async {
    try {
      final allRoomsResponse = await roomDataSource.getAllRooms(
        token: token,
        limit: limit,
        offset: offset,
        onlyDuets: onlyDuets,
        onlyGroups: onlyGroups,
        requiredDetailedRoomUserData: requiredDetailedRoomUserData,
      );

      final response = getDecodedDataFromResponse(allRoomsResponse);

      final List<Map<String, dynamic>> roomList =
          response.data.get('rooms') ?? <String, dynamic>{};

      if (isEmptyEntity(roomList)) throw Exception("No response");

      final List<Room> rooms = roomList
          .map((room) => Room(
                roomId: room.get('roomId', ''),
                roomName: room.get('roomName', ''),
                roomLogoUrl: room.get('roomLogoUrl', ''),
                roomType: room.get('roomType', ''),
                createdByUserId: room.get('createdByUserId', ''),
                roomDescription: room.get('roomDescription', ''),
                createdAt: room.get('createdAt', ''),
                updatedAt: room.get('updatedAt', ''),
              ))
          .toList();

      return Response(
          code: allRoomsResponse?.statusCode ?? 200,
          status: response.status,
          response: rooms);
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
