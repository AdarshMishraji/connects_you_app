class MessageSeenInfo {
  final String messageId;
  final int messageSeenAt;
  final String messageSeenByUserId;

  const MessageSeenInfo({
    required this.messageId,
    required this.messageSeenAt,
    required this.messageSeenByUserId,
  });

  Map<String, dynamic> toMap() => {
        "messageId": messageId,
        "messageSeenAt": messageSeenAt,
        "messageSeenByUserId": messageSeenByUserId
      };
}

class Message {
  final String messageId;
  final String messageText;
  final String messageType;
  final String senderUserId;
  final String recieverUserId;
  final String replyMessageId;
  final String roomId;
  final String haveThreadId;
  final String belongsToThreadId;
  final int sendAt;
  final int updatedAt;
  final List<MessageSeenInfo>? messageSeenInfo;
  final bool isSent;

  const Message({
    required this.messageId,
    required this.messageText,
    required this.messageType,
    required this.senderUserId,
    this.recieverUserId = '',
    this.replyMessageId = '',
    required this.roomId,
    this.haveThreadId = '',
    this.belongsToThreadId = '',
    required this.sendAt,
    required this.updatedAt,
    this.messageSeenInfo,
    this.isSent = false,
  });

  List<Map<String, dynamic>> get messageSeenInfoListMap {
    if (messageSeenInfo != null) {
      return messageSeenInfo!.map((info) => info.toMap()).toList();
    }
    return [];
  }
}
