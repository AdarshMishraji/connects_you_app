import 'package:connects_you/data/localDB/DBOps.dart';
import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/extensions/iterable.dart';
import 'package:flutter/rendering.dart';

class UserOpsDataSource {
  const UserOpsDataSource._();
  static const _instance = UserOpsDataSource._();
  static const instance = _instance;

  Future<int> insertLocalUsers(List<LocalDBUser> users) async {
    if (users.isNotEmpty) {
      final query = """INSERT OR IGNORE INTO ${TableNames.users} (
        ${UsersTableColumns.userId},
        ${UsersTableColumns.email},
        ${UsersTableColumns.name},
        ${UsersTableColumns.photo},
        ${UsersTableColumns.publicKey},
        ${UsersTableColumns.privateKey}
      ) VALUES ${users.map((user) => """
                 "${user.userId}",
                 "${user.email}",
                 "${user.name}",
                 "${user.photo}",
                 "${user.publicKey}",
                 "${user.privateKey}"
              """)}""";
      final db = await DBOpsDataSource.instance.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('users inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> fetchLocalUserWithUserId(
      String userId) async {
    final db = await DBOpsDataSource.instance.getDB();
    return await db.query(TableNames.users, where: "userId = '$userId'");
  }

  Future<List<Map<String, dynamic>>> fetchLocalUsersWithUserIds(
      List<String> userIds) async {
    final db = await DBOpsDataSource.instance.getDB();
    return await db.query(TableNames.users,
        where: "userId IN (${userIds.toStringWithoutBrackets()})");
  }

  Future<List<Map<String, dynamic>>> fetchLocalUsers(
      [String? exceptedUserId]) async {
    final db = await DBOpsDataSource.instance.getDB();
    return db.query(TableNames.users,
        where: exceptedUserId == null ? null : 'userId != $exceptedUserId');
  }
}
