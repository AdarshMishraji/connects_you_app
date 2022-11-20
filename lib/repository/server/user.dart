import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/data/server/auth.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:connects_you/data/server/user.dart';
import 'package:connects_you/repository/server/_helper.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class UserRepository {
  UserRepository._();

  static final UserRepository _instance = UserRepository._();

  factory UserRepository() {
    return _instance;
  }

  final UserDataSource userDataSource = UserDataSource();

  Future<Response<User>?> getUserDetails({
    required String token,
    required String userId,
  }) async {
    try {
      final userDetailsResponse = await userDataSource.getUserDetails(
        token: token,
        userId: userId,
      );

      final response = getDecodedDataFromResponse(userDetailsResponse);

      final Map<String, dynamic> user =
          response.data.get('user') ?? <String, dynamic>{};

      if (isEmptyEntity(user)) throw Exception("No response");

      return Response(
        code: userDetailsResponse?.statusCode ?? 200,
        status: response.status,
        response: User(
          userId: user.get('userId', ''),
          name: user.get('name', ''),
          email: user.get('email', ''),
          publicKey: user.get('publicKey', ''),
          photoUrl: user.get('photoUrl', ''),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<List<User>>?> getAllUsers({
    required String token,
    String? myUserId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final allUsersResponse = await userDataSource.getAllUsers(
        token: token,
        myUserId: myUserId,
        limit: limit,
        offset: offset,
      );

      final response = getDecodedDataFromResponse(allUsersResponse);

      final List<Map<String, dynamic>> usersList =
          response.data.get('users') ?? <Map<String, dynamic>>[];

      if (isEmptyEntity(usersList)) throw Exception("No response");

      final List<User> users = usersList
          .map((user) => User(
                userId: user.get('userId', ''),
                name: user.get('name', ''),
                email: user.get('email', ''),
                publicKey: user.get('publicKey', ''),
                photoUrl: user.get('photoUrl', ''),
              ))
          .toList();

      return Response(
        code: allUsersResponse?.statusCode ?? 200,
        status: response.status,
        response: users,
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<Response<User>?> getMyDetails({required String token}) async {
    try {
      final myDetailsResponse = await userDataSource.getMyDetails(
        token: token,
      );

      final response = getDecodedDataFromResponse(myDetailsResponse);

      final Map<String, dynamic> user =
          response.data.get('user') ?? <String, dynamic>{};

      if (isEmptyEntity(user)) throw Exception("No response");

      return Response(
        code: myDetailsResponse?.statusCode ?? 200,
        status: response.status,
        response: User(
          userId: user.get('userId', ''),
          name: user.get('name', ''),
          email: user.get('email', ''),
          publicKey: user.get('publicKey', ''),
          photoUrl: user.get('photoUrl', ''),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }
}
