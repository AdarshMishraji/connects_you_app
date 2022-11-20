import 'package:connects_you/data/models/message.dart';

class Room {
  final String roomId;
  final String roomName;
  final String roomLogoUrl;
  final String roomDescription;
  final String roomType;
  final String createdByUserId;
  final int createdAt; // timestamp in form of string
  final int updatedAt;
  final List<Message>? messages;

  const Room({
    required this.roomId,
    required this.roomName,
    required this.roomLogoUrl,
    required this.roomDescription,
    required this.roomType,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });
}

class RoomUser {
  final String roomId;
  final String userId;
  final String userRole;
  final int joinedAt;

  const RoomUser({
    required this.roomId,
    required this.userId,
    required this.userRole,
    required this.joinedAt,
  });
}
