import 'package:connects_you/localDB/messageOps.dart';
import 'package:connects_you/localDB/roomOps.dart';
import 'package:connects_you/localDB/sharedKeysOps.dart';
import 'package:connects_you/localDB/userOps.dart';

class LocalDBOps {
  static const UserOps userOps = UserOps();
  static const RoomOps roomOps = RoomOps();
  static const MessageOps messageOps = MessageOps();
  static const SharedKeysOps sharedKeysOps = SharedKeysOps();
}
