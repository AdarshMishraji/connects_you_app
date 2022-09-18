import 'package:connects_you/data/models/message.dart';
import 'package:connects_you/enums/room.dart';

class Room {
  final String roomId;
  final String roomName;
  final String roomLogo;
  final String roomDescription;
  final RoomType roomType;
  final String createdByUserId;
  final int createdAt; // timestamp in form of string
  final int updatedAt;
  final List<Message>? messages;

  const Room({
    required this.roomId,
    required this.roomName,
    required this.roomLogo,
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
  final RoomUserRole userRole;
  final int joinedAt;

  const RoomUser({
    required this.roomId,
    required this.userId,
    required this.userRole,
    required this.joinedAt,
  });
}
