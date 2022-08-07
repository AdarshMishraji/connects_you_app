import 'dart:convert';

import 'package:connects_you/enums/room.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/extensions/string.dart';
import 'package:connects_you/localDB/DBProvider.dart';
import 'package:connects_you/localDB/DDLs.dart';
import 'package:connects_you/models/message.dart';
import 'package:connects_you/models/room.dart';
import 'package:flutter/rendering.dart';

class RoomOps {
  const RoomOps();

  Future<int> insertLocalRooms(List<Room> rooms) async {
    if (rooms.isNotEmpty) {
      final query = """INSERT OR IGNORE INTO ${TableNames.rooms} (
            ${RoomsTableColumns.roomId},
            ${RoomsTableColumns.roomName},
            ${RoomsTableColumns.roomLogo},
            ${RoomsTableColumns.roomDescription},
            ${RoomsTableColumns.roomType},
            ${RoomsTableColumns.createdByUserId},
            ${RoomsTableColumns.createdAt},
            ${RoomsTableColumns.updatedAt}
          ) VALUES 
            ${rooms.map((room) => {
                RoomsTableColumns.roomId: room.roomId,
                RoomsTableColumns.roomName: room.roomName,
                RoomsTableColumns.roomLogo: room.roomLogo,
                RoomsTableColumns.roomDescription: room.roomDescription,
                RoomsTableColumns.roomType: room.roomType.value,
                RoomsTableColumns.createdByUserId: room.createdByUserId,
                RoomsTableColumns.createdAt: room.createdAt.toString(),
                RoomsTableColumns.updatedAt: room.updatedAt.toString(),
              })}""";
      final db = await DBProvider.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('rooms inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  Future<int> insertLocalRoomUsers(List<RoomUser> roomUsers) async {
    if (roomUsers.isNotEmpty) {
      final query = """INSERT OR IGNORE INTO ${TableNames.roomUsers} (
            ${RoomUsersTableColumns.roomId},
            ${RoomUsersTableColumns.userId},
            ${RoomUsersTableColumns.userRole},
            ${RoomUsersTableColumns.joinedAt}
          ) VALUES 
            ${roomUsers.map((roomUser) => {
                RoomUsersTableColumns.roomId: roomUser.roomId,
                RoomUsersTableColumns.userId: roomUser.userId,
                RoomUsersTableColumns.userRole: roomUser.userRole.value,
                RoomUsersTableColumns.joinedAt: roomUser.joinedAt.toString(),
              })}""";
      final db = await DBProvider.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('roomUsers inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  List<Room> _createResponseToSendForRooms(List<Map<String, dynamic>> rooms) {
    List<Room> dataToSend = [];
    for (var room in rooms) {
      dataToSend.add(Room(
        roomId: room.get(RoomsTableColumns.roomId, ''),
        roomName: room.get(RoomsTableColumns.roomName, ''),
        roomLogo: room.get(RoomsTableColumns.roomLogo, ''),
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

  Future<List<RoomUser>?> fetchLocalRoomUsers() async {
    final db = await DBProvider.getDB();
    final List<Map<String, dynamic>> response =
        await db.query(TableNames.roomUsers);
    return _createDataToSendForRoomUsers(response);
  }

  Future<List<Room>?> fetchLocalRoomACCUserId(
    String userId,
    RoomType roomType,
  ) async {
    final query = """SELECT 
                       *
                      FROM
                        ${TableNames.rooms} 
                      WHERE
                        roomId = (
                          SELECT 
                            DISTINCT(roomId) 
                          FROM 
                            ${TableNames.roomUsers} 
                          WHERE 
                            userId = "$userId" 
                          AND 
                            userRole IN ${roomType == RoomType.DUET ? '("${RoomUserRole.DUET_CREATOR}", "${RoomUserRole.DUET_NORMAL}")' : roomType == RoomType.GROUP ? '("${RoomUserRole.GROUP_ADMIN}", "${RoomUserRole.GROUP_NORMAL}", "${RoomUserRole.GROUP_CREATOR}")' : ''})""";
    final db = await DBProvider.getDB();
    final List<Map<String, dynamic>> response = await db.rawQuery(query);
    return _createResponseToSendForRooms(response);
  }

  Future<List<RoomUser>?> fetchLocalRoomUsersACCRoomId(
    String roomId,
    RoomType roomType,
    String exceptedUserId,
  ) async {
    final query = """SELECT  
                       *
                      FROM 
                        ${TableNames.roomUsers}
                      WHERE
                        roomId = "$roomId" 
                      AND 
                        userRole IN ${roomType == RoomType.DUET ? '("${RoomUserRole.DUET_CREATOR}", "${RoomUserRole.DUET_NORMAL}")' : roomType == RoomType.GROUP ? '("${RoomUserRole.GROUP_ADMIN}", "${RoomUserRole.GROUP_NORMAL}", "${RoomUserRole.GROUP_CREATOR}")' : ''} 
                      AND
                        userId != "$exceptedUserId"; """;
    final db = await DBProvider.getDB();
    final List<Map<String, dynamic>> response = await db.rawQuery(query);
    return _createDataToSendForRoomUsers(response);
  }

  /// we are suppose to fetch last 25 (limit 25 desc) messages rooms and store in inside provider.
  /// and inside the chat room screen on reaching end, we fetch another 50 messages and store in inside provider/store
  Future<List<Room>> fetchInitialLocalRoomMessages() async {
    const query = """ WITH sorted_messages AS (
                        SELECT 
                          * 
                        FROM 
                          ${TableNames.messages} 
                        ORDER BY 
                          updatedAt DESC
                      )
                    SELECT 
                      r.*, 
                      (
                        SELECT 
                          JSON_GROUP_ARRAY(JSON(res))
                        FROM (
                          SELECT JSON_OBJECT(
                            '_id', _id,
                            'messageId', messageId,
                            'messageText', messageText,
                            'messageType', messageType,
                            'senderUserId', senderUserId,
                            'recieverUserId', recieverUserId,
                            'roomId', roomId,
                            'replyMessageId', replyMessageId,
                            'sendAt', sendAt,
                            'updatedAt', updatedAt,
                            'messageSeenInfo', messageSeenInfo,
                            'isSent', isSent,
                            'haveThreadId', haveThreadId,
                            'belongsToThreadId', belongsToThreadId
                          ) AS res
                            FROM 
                              sorted_messages 
                            WHERE
                              roomId = r.roomId
                            LIMIT 25
                        )
                      ) AS messages
                    FROM 
                      ${TableNames.rooms} r 
                  """;
    final db = await DBProvider.getDB();
    final List<Map<String, dynamic>> response = await db.rawQuery(query);
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
          recieverUserId: message.get(MessagesTableColumns.recieverUserId, ''),
          replyMessageId: message.get(MessagesTableColumns.replyMessageId, ''),
        ));
      }
      dataToSend.add(Room(
        roomId: room.get(RoomsTableColumns.roomId, ''),
        roomName: room.get(RoomsTableColumns.roomName, ''),
        roomLogo: room.get(RoomsTableColumns.roomLogo, ''),
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
  }
}

// if user changes it's details then room logo and name is not updating (Check it once)
