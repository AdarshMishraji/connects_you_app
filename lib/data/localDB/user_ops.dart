import 'package:connects_you/data/localDB/db_ops.dart';
import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class UserOpsDataSource {
  const UserOpsDataSource._();

  static const _instance = UserOpsDataSource._();

  factory UserOpsDataSource() {
    return _instance;
  }

  Future<int> insertLocalUsers(List<LocalDBUser> users) async {
    if (users.isNotEmpty) {
      final query = """INSERT OR IGNORE INTO ${TableNames.users} (
        ${UsersTableColumns.userId},
        ${UsersTableColumns.email},
        ${UsersTableColumns.name},
        ${UsersTableColumns.photoUrl},
        ${UsersTableColumns.publicKey},
        ${UsersTableColumns.privateKey}
      ) VALUES ${users.map((user) => """
                 "${user.userId}",
                 "${user.email}",
                 "${user.name}",
                 "${user.photoUrl}",
                 "${user.publicKey}",
                 "${user.privateKey}"
              """)}""";
      final db = await DBOpsDataSource().getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('users inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> fetchLocalUserWithUserId(
      String userId) async {
    final db = await DBOpsDataSource().getDB();
    return await db.query(TableNames.users, where: "userId = '$userId'");
  }

  Future<List<Map<String, dynamic>>> fetchLocalUsersWithUserIds(
      List<String> userIds) async {
    final db = await DBOpsDataSource().getDB();
    return await db.query(TableNames.users,
        where: "userId IN (${userIds.toStringWithoutBrackets()})");
  }

  Future<List<Map<String, dynamic>>> fetchLocalUsers(
      [String? exceptedUserId]) async {
    final db = await DBOpsDataSource().getDB();
    return db.query(TableNames.users,
        where: exceptedUserId == null ? null : 'userId != $exceptedUserId');
  }
}
