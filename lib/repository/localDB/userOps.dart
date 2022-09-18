import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/localDB/userOps.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:flutter/rendering.dart';

class UserOpsRepository {
  const UserOpsRepository();

  final UserOpsDataSource userOpsDataSource = UserOpsDataSource.instance;

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

  Future<int> insertLocalUsers(List<LocalDBUser> users) async {
    try {
      final response = await userOpsDataSource.insertLocalUsers(users);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<LocalDBUser?> fetchLocalUserWithUserId(String userId) async {
    try {
      final response = await userOpsDataSource.fetchLocalUserWithUserId(userId);
      final users = _createResponse(response);
      return users.isEmpty ? null : users[0];
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<List<LocalDBUser>> fetchLocalUsersWithUserIds(
      List<String> userIds) async {
    try {
      final response =
          await userOpsDataSource.fetchLocalUsersWithUserIds(userIds);
      return _createResponse(response);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  Future<List<LocalDBUser>> fetchLocalUsers([String? exceptedUserId]) async {
    try {
      final response = await userOpsDataSource.fetchLocalUsers(exceptedUserId);
      return _createResponse(response);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }
}
