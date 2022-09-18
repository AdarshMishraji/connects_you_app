import 'dart:convert';

import 'package:connects_you/data/localDB/DBOps.dart';
import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/models/message.dart';
import 'package:connects_you/extensions/iterable.dart';
import 'package:flutter/rendering.dart';

class MessageOpsDataSource {
  const MessageOpsDataSource._();
  static const _instance = MessageOpsDataSource._();
  static const instance = _instance;

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
      final db = await DBOpsDataSource.instance.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('messages inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  Future<List<Map<String, Object?>>> fetchLocalMessagesACCRoomId(String roomId,
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
    final db = await DBOpsDataSource.instance.getDB();
    return await db.rawQuery(query);
  }

  Future<List<Map<String, Object?>>> fetchLocalRoomMessages(
      String roomId) async {
    final db = await DBOpsDataSource.instance.getDB();
    return await db.query(TableNames.messages, where: "roomId = $roomId");
  }

  Future<int> deleteLocalRoomMessages(
      List<String> messageIds, String roomId) async {
    final db = await DBOpsDataSource.instance.getDB();
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
    final db = await DBOpsDataSource.instance.getDB();
    final updatedRows = await db.rawUpdate(query);
    debugPrint('message seen info updated $updatedRows');
    return updatedRows;
  }

  Future<int> updateLocalMessageSent(List<String> messageIds) async {
    final db = await DBOpsDataSource.instance.getDB();
    final updatedRows = await db.update(
        TableNames.messages, {MessagesTableColumns.isSent: true},
        where: "messageId in (${messageIds.toStringWithoutBrackets()})");
    debugPrint('message sent sent to true $updatedRows');
    return updatedRows;
  }

  Future<List<Map<String, Object?>>> fetchUnSentMessages(
      String myUserId) async {
    final db = await DBOpsDataSource.instance.getDB();
    return await db.query(TableNames.messages, where: "isSent = false");
  }

  // thread manipulation methods are remaining to be coded.
}
