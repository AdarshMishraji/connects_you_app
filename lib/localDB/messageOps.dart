import 'dart:convert';

import 'package:connects_you/extensions/iterable.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/extensions/string.dart';
import 'package:connects_you/localDB/DBProvider.dart';
import 'package:connects_you/localDB/DDLs.dart';
import 'package:connects_you/models/message.dart';
import 'package:flutter/rendering.dart';

class MessageOps {
  const MessageOps();

  Future<int> insertMessages(List<Message> messages) async {
    if (messages.isNotEmpty) {
      final query = """INSERT OR REPLACE INTO ${TableNames.messages} (
          ${MessagesTableColumns.messageId},
          ${MessagesTableColumns.messageText},
          ${MessagesTableColumns.messageType},
          ${MessagesTableColumns.senderUserId},
          ${MessagesTableColumns.recieverUserId},
          ${MessagesTableColumns.roomId},
          ${MessagesTableColumns.replyMessageId},
          ${MessagesTableColumns.sendAt},
          ${MessagesTableColumns.updatedAt},
          ${MessagesTableColumns.messageSeenInfo},
          ${MessagesTableColumns.isSent}
        ) VALUES ${messages.map((message) => {
                MessagesTableColumns.messageId: message.messageId,
                MessagesTableColumns.messageText: message.messageText,
                MessagesTableColumns.messageType: message.messageType,
                MessagesTableColumns.senderUserId: message.senderUserId,
                MessagesTableColumns.recieverUserId: message.recieverUserId,
                MessagesTableColumns.roomId: message.roomId,
                MessagesTableColumns.replyMessageId: message.replyMessageId,
                MessagesTableColumns.sendAt: message.sendAt,
                MessagesTableColumns.updatedAt: message.updatedAt,
                MessagesTableColumns.messageSeenInfo:
                    "'${jsonEncode(message.messageSeenInfoListMap)}'",
                MessagesTableColumns.isSent: message.isSent,
              })} """;
      final db = await DBProvider.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('messages inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  List<Message> _createResponseToSendForMessage(
      List<Map<String, dynamic>> messages,
      [bool havingMessageSeenInfo = false]) {
    List<Message> dataToSend = [];
    for (var message in messages) {
      dynamic messageSeenInfo;
      if (havingMessageSeenInfo) {
        final messageSeenInfoMap = (jsonDecode(
            message.get(MessagesTableColumns.messageSeenInfo) as String? ??
                '{}')) as Map<String, dynamic>;
        if (messageSeenInfoMap.isNotEmpty) {
          messageSeenInfo = MessageSeenInfo(
            messageId: messageSeenInfoMap.get('messageId', ''),
            messageSeenAt: messageSeenInfoMap.get('messageSeenAt', ''),
            messageSeenByUserId:
                messageSeenInfoMap.get('messageSeenByUserId', ''),
          );
        }
      }
      dataToSend.add(Message(
        messageId: message.get(MessagesTableColumns.messageId, ''),
        messageText: message.get(MessagesTableColumns.messageText, ''),
        messageType: message.get(MessagesTableColumns.messageType, ''),
        senderUserId: message.get(MessagesTableColumns.senderUserId, ''),
        roomId: message.get(MessagesTableColumns.roomId, ''),
        sendAt: ((message.get(MessagesTableColumns.sendAt, '') as String)
                .tryParseInt() ??
            -1),
        updatedAt: ((message.get(MessagesTableColumns.updatedAt, '') as String)
                .tryParseInt() ??
            -1),
        recieverUserId: message.get(MessagesTableColumns.recieverUserId, ''),
        replyMessageId: message.get(MessagesTableColumns.replyMessageId, ''),
        messageSeenInfo: messageSeenInfo,
        isSent: message.get(MessagesTableColumns.isSent, ''),
        haveThreadId: message.get(MessagesTableColumns.haveThreadId, ''),
        belongsToThreadId:
            message.get(MessagesTableColumns.belongsToThreadId, ''),
      ));
    }
    return dataToSend;
  }

  Future<List<Message>> fetchLocalMessagesACCRoomId(String roomId,
      [int offset = -1, limit = -1]) async {
    final query = """SELECT 
                        *
                      FROM 
                        ${TableNames.messages}
                      WHERE
                        roomId = "$roomId" ${offset >= 0 ? 'AND _id > $offset' : ''}
                      ORDER BY updatedAt DESC
                      ${limit >= 0 ? 'LIMIT $limit' : ''}
                      """;
    final db = await DBProvider.getDB();
    final response = await db.rawQuery(query);
    return _createResponseToSendForMessage(response, true);
  }

  Future<List<Message>> fetchLocalRoomMessages(String roomId) async {
    final db = await DBProvider.getDB();
    final response =
        await db.query(TableNames.messages, where: "roomId = $roomId");
    return _createResponseToSendForMessage(response, true);
  }

  Future<int> deleteLocalRoomMessages(
      List<String> messageIds, String roomId) async {
    final db = await DBProvider.getDB();
    final deletedRows = await db.delete(TableNames.messages,
        where:
            "roomId = $roomId AND messageId IN (${messageIds.toStringWithoutBrackets()})");
    debugPrint('messages deleted $deletedRows');
    return deletedRows;
  }

  Future<int> updateLocalMessageSeenInfo(
    List<String> messageIds,
    String roomId,
    String myUserId,
    String time,
  ) async {
    final query = """UPDATE 
                        ${TableNames.messages} 
                      SET
                        messageSeenInfo = JSON_INSERT(
                                            messageSeenInfo,
                                            '\$[' || json_array_length(messageSeenInfo) || ']',
                                            json('{"messageSeenByUserId": "$myUserId","messageSeenAt": $time}')
                                          )
                      WHERE
                        roomId='$roomId'
                      AND 
                        messageId IN (${messageIds.toStringWithoutBrackets()})""";
    final db = await DBProvider.getDB();
    final updatedRows = await db.rawUpdate(query);
    debugPrint('message seen info updated $updatedRows');
    return updatedRows;
  }

  Future<int> updateLocalMessageSent(List<String> messageIds) async {
    final db = await DBProvider.getDB();
    final updatedRows = await db.update(
        TableNames.messages, {MessagesTableColumns.isSent: true},
        where: "messageId in (${messageIds.toStringWithoutBrackets()})");
    debugPrint('message sent sent to true $updatedRows');
    return updatedRows;
  }

  Future<List<Message>> fetchUnSentMessages(String myUserId) async {
    final db = await DBProvider.getDB();
    final response =
        await db.query(TableNames.messages, where: "isSent = false");
    return _createResponseToSendForMessage(response);
  }

  // thread manipulation methods are remaining to be coded.
}
