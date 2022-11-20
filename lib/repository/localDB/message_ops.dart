import 'dart:convert';

import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/localDB/message_ops.dart';
import 'package:connects_you/data/models/message.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class MessageOpsRepository {
  MessageOpsRepository._();

  static final MessageOpsRepository _instance = MessageOpsRepository._();

  factory MessageOpsRepository() {
    return _instance;
  }

  final MessageOpsDataSource messageOpsDataSource = MessageOpsDataSource();

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
        receiverUserId: message.get(MessagesTableColumns.receiverUserId, ''),
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

  Future<int> insertMessages(List<Message> messages) async {
    try {
      return await messageOpsDataSource.insertMessages(messages);
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<List<Message>> fetchLocalMessagesACCRoomId(String roomId,
      [int offset = -1, limit = -1]) async {
    try {
      final response = await messageOpsDataSource.fetchLocalMessagesACCRoomId(
          roomId, offset, limit);
      return _createResponseToSendForMessage(response, true);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  Future<List<Message>> fetchLocalRoomMessages(String roomId) async {
    try {
      final response =
          await messageOpsDataSource.fetchLocalRoomMessages(roomId);
      return _createResponseToSendForMessage(response, true);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  Future<int> deleteLocalRoomMessages(
      List<String> messageIds, String roomId) async {
    try {
      final response = await messageOpsDataSource.deleteLocalRoomMessages(
          messageIds, roomId);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<int> updateLocalMessageSeenInfo(
    List<String> messageIds,
    String roomId,
    String myUserId,
    String time,
  ) async {
    try {
      final response = await messageOpsDataSource.updateLocalMessageSeenInfo(
          messageIds, roomId, myUserId, time);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<int> updateLocalMessageSent(List<String> messageIds) async {
    try {
      final response =
          await messageOpsDataSource.updateLocalMessageSent(messageIds);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<List<Message>> fetchUnSentMessages(String myUserId) async {
    try {
      final response = await messageOpsDataSource.fetchUnSentMessages(myUserId);
      return _createResponseToSendForMessage(response, false);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }
}
