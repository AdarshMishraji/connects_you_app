import 'package:connects_you/constants/response_status.dart';
import 'package:connects_you/data/server/endpoints.dart';
import 'package:connects_you/data/server/server.dart';

import 'package:dart_utils/dart_utils.dart';
import 'package:http_wrapper/http.dart';

class UserDataSource {
  const UserDataSource._();
  static const _instance = UserDataSource._();

  factory UserDataSource() {
    return _instance;
  }

  Future<DecodedResponse?> getUserDetails({
    required String token,
    required String userId,
  }) async {
    final userDetailsResponse = await Server().get(
        endpoint: createQueryUrl(
            Endpoints.userDetails,
            {
              'userId': userId,
            }.removeNulls() as Map<String, String>),
        headers: {'token': token});
    if (userDetailsResponse.statusCode == StatusCodes.SUCCESS) {
      return userDetailsResponse;
    }
    throw Exception({"statusCode": userDetailsResponse.statusCode});
  }

  Future<DecodedResponse?> getAllUsers({
    required String token,
    String? myUserId,
    int limit = 10,
    int offset = 0,
  }) async {
    final allUsersResponse = await Server().get(
        endpoint: createQueryUrl(
            Endpoints.allUsers,
            {
              'exceptUserId': myUserId!,
              'limit': limit.toString(),
              'offset': offset.toString(),
            }.removeNulls() as Map<String, String>),
        headers: {'token': token});
    if (allUsersResponse.statusCode == StatusCodes.SUCCESS) {
      return allUsersResponse;
    }
    throw Exception({"statusCode": allUsersResponse.statusCode});
  }

  Future<DecodedResponse?> getMyDetails({
    required String token,
  }) async {
    final myDetailsResponse = await Server()
        .get(endpoint: Endpoints.myDetails, headers: {'token': token});
    if (myDetailsResponse.statusCode == StatusCodes.SUCCESS) {
      return myDetailsResponse;
    }
    throw Exception({"statusCode": myDetailsResponse.statusCode});
  }
}
