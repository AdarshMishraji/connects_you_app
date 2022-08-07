import 'package:connects_you/extensions/iterable.dart';
import 'package:connects_you/localDB/DBProvider.dart';
import 'package:connects_you/localDB/DDLs.dart';
import 'package:connects_you/models/user.dart';
import 'package:flutter/rendering.dart';

class UserOps {
  const UserOps();

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
      final db = await DBProvider.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('users inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  List<LocalDBUser> _createResponse(List<Map<String, dynamic>> users) {
    return users
        .map((user) => LocalDBUser(
              userId: user[UsersTableColumns.userId]!,
              name: user[UsersTableColumns.name]!,
              email: user[UsersTableColumns.email]!,
              photo: user[UsersTableColumns.photo]!,
              publicKey: user[UsersTableColumns.publicKey]!,
              privateKey: user[UsersTableColumns.privateKey]!,
            ))
        .toList();
  }

  Future<LocalDBUser?> fetchLocalUserWithUserId(String userId) async {
    final db = await DBProvider.getDB();
    return db
        .query(TableNames.users, where: "userId = '$userId'")
        .then((response) {
      final users = _createResponse(response);
      return users.isEmpty ? null : users[0];
    });
  }

  Future<List<LocalDBUser>?> fetchLocalUsersWithUserIds(
      List<String> userIds) async {
    final db = await DBProvider.getDB();
    return db
        .query(TableNames.users,
            where: "userId IN (${userIds.toStringWithoutBrackets()})")
        .then(_createResponse);
  }

  Future<List<LocalDBUser>?> fetchLocalUsers([String? exceptedUserId]) async {
    final db = await DBProvider.getDB();
    return db
        .query(TableNames.users,
            where: exceptedUserId == null ? null : 'userId != $exceptedUserId')
        .then(_createResponse);
  }
}
