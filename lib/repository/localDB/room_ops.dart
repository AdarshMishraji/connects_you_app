import 'dart:convert';

import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/localDB/room_ops.dart';
import 'package:connects_you/data/models/message.dart';
import 'package:connects_you/data/models/room.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class RoomOpsRepository {
  RoomOpsRepository._();

  static final RoomOpsRepository _instance = RoomOpsRepository._();

  factory RoomOpsRepository() {
    return _instance;
  }

  final RoomOpsDataSource roomOpsDataSource = RoomOpsDataSource();

  List<Room> _createResponseToSendForRooms(List<Map<String, dynamic>> rooms) {
    List<Room> dataToSend = [];
    for (var room in rooms) {
      dataToSend.add(Room(
        roomId: room.get(RoomsTableColumns.roomId, ''),
        roomName: room.get(RoomsTableColumns.roomName, ''),
        roomLogoUrl: room.get(RoomsTableColumns.roomLogoUrl, ''),
        roomDescription: room.get(RoomsTableColumns.roomDescription, ''),
        roomType: room.get(RoomsTableColumns.roomType, ''),
        createdByUserId: room.get(RoomsTableColumns.createdByUserId, ''),
        createdAt: ((room.get(RoomsTableColumns.createdAt, '') as String)
                .tryParseInt() ??
            -1),
        updatedAt: ((room.get(RoomsTableColumns.updatedAt, '') as String)
                .tryParseInt() ??
            -1),
      ));
    }
    return dataToSend;
  }

  List<RoomUser> _createDataToSendForRoomUsers(
    List<Map<String, dynamic>> roomUsers,
  ) {
    List<RoomUser> dataToSend = [];
    for (var roomUser in roomUsers) {
      dataToSend.add(
        RoomUser(
          roomId: roomUser.get(RoomUsersTableColumns.roomId, ''),
          userId: roomUser.get(RoomUsersTableColumns.userId, ''),
          userRole: roomUser.get(RoomUsersTableColumns.userRole, ''),
          joinedAt:
              ((roomUser.get(RoomUsersTableColumns.joinedAt, '') as String)
                      .tryParseInt() ??
                  -1),
        ),
      );
    }
    return dataToSend;
  }

  Future<int> insertLocalRooms(List<Room> rooms) async {
    try {
      final response = await roomOpsDataSource.insertLocalRooms(rooms);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<int> insertLocalRoomUsers(List<RoomUser> roomUsers) async {
    try {
      final response = await roomOpsDataSource.insertLocalRoomUsers(roomUsers);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<List<RoomUser>?> fetchLocalRoomUsers() async {
    try {
      final response = await roomOpsDataSource.fetchLocalRoomUsers();
      return _createDataToSendForRoomUsers(response);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  Future<List<Room>?> fetchLocalRoomACCUserId(
    String userId,
    String roomType,
  ) async {
    try {
      final response =
          await roomOpsDataSource.fetchLocalRoomACCUserId(userId, roomType);
      return _createResponseToSendForRooms(response);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  /// we are suppose to fetch last 25 (limit 25 desc) messages rooms and store in inside provider.
  /// and inside the chat room screen on reaching end, we fetch another 50 messages and store in inside provider/store
  Future<List<Room>?> fetchInitialLocalMessages() async {
    try {
      final response = await roomOpsDataSource.fetchInitialLocalRoomMessages();
      List<Room> dataToSend = [];
      for (var room in response) {
        List<Message> messages = [];
        final roomMessages = jsonDecode(room.get('messages') ?? '{}')
            as List<Map<String, dynamic>>;
        for (var message in roomMessages) {
          List<MessageSeenInfo> messageSeenInfo = [];
          final messageSeenInfos = jsonDecode(
                  message.get(MessagesTableColumns.messageSeenInfo) ?? '{}')
              as List<Map<String, dynamic>>;
          for (var info in messageSeenInfos) {
            messageSeenInfo.add(MessageSeenInfo(
              messageId: info.get('messageId', ''),
              messageSeenAt: info.get('messageSeenAt', ''),
              messageSeenByUserId: info.get('messageSeenByUserId', ''),
            ));
          }
          messages.add(Message(
            messageId: message.get(MessagesTableColumns.messageId, ''),
            messageText: message.get(MessagesTableColumns.messageId, ''),
            messageType: message.get(MessagesTableColumns.messageId, ''),
            senderUserId: message.get(MessagesTableColumns.messageId, ''),
            roomId: message.get(MessagesTableColumns.messageId, ''),
            sendAt: ((message.get(MessagesTableColumns.sendAt, '') as String)
                    .tryParseInt() ??
                -1),
            updatedAt:
                ((message.get(MessagesTableColumns.updatedAt, '') as String)
                        .tryParseInt() ??
                    -1),
            belongsToThreadId: message.get(MessagesTableColumns.messageId, ''),
            haveThreadId: message.get(MessagesTableColumns.messageId, ''),
            isSent: message.get(MessagesTableColumns.messageId, ''),
            messageSeenInfo: messageSeenInfo,
            receiverUserId:
                message.get(MessagesTableColumns.receiverUserId, ''),
            replyMessageId:
                message.get(MessagesTableColumns.replyMessageId, ''),
          ));
        }
        dataToSend.add(Room(
          roomId: room.get(RoomsTableColumns.roomId, ''),
          roomName: room.get(RoomsTableColumns.roomName, ''),
          roomLogoUrl: room.get(RoomsTableColumns.roomLogoUrl, ''),
          roomDescription: room.get(RoomsTableColumns.roomDescription, ''),
          roomType: room.get(RoomsTableColumns.roomType, ''),
          createdByUserId: room.get(RoomsTableColumns.createdByUserId, ''),
          createdAt: ((room.get(RoomsTableColumns.createdAt, '') as String)
                  .tryParseInt() ??
              -1),
          updatedAt: ((room.get(RoomsTableColumns.updatedAt, '') as String)
                  .tryParseInt() ??
              -1),
          messages: messages,
        ));
      }
      return dataToSend;
      // sort the result as per latest message's updatedAt,
      // create map, roomId as key,
      // latestRoomUpdatedAt, and latestMessageUpdatedAt can be found easily after above 2 steps
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }
}
