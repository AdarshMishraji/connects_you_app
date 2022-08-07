import 'package:connects_you/models/room.dart';

class CachedData {
  final List<Room> roomData;
  // ignore: todo
  final dynamic messages; // TODO: // handle data for dynamic fields;
  final dynamic notifications;
  final dynamic encryptedStrings;

  const CachedData({
    required this.roomData,
    required this.messages,
    required this.notifications,
    required this.encryptedStrings,
  });
}
