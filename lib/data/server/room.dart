import 'package:connects_you/constants/response_status.dart';
import 'package:connects_you/data/server/endpoints.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:http_wrapper/http.dart';

class RoomDataSource {
  const RoomDataSource._();
  static const _instance = RoomDataSource._();

  factory RoomDataSource() {
    return _instance;
  }

  Future<DecodedResponse?> getAllRooms({
    required String token,
    int limit = 10,
    int offset = 0,
    bool onlyDuets = false,
    bool onlyGroups = false,
    bool requiredDetailedRoomUserData = true,
  }) async {
    final allUsersResponse = await Server().get(
        endpoint: createQueryUrl(
            Endpoints.allUsers,
            {
              'limit': limit.toString(),
              'offset': offset.toString(),
              'onlyDuets': onlyDuets.toString(),
              'onlyGroups': onlyGroups.toString(),
              'requiredDetailedRoomUserData':
                  requiredDetailedRoomUserData.toString(),
            }.removeNulls() as Map<String, String>),
        headers: {'token': token});
    if (allUsersResponse.statusCode == StatusCodes.SUCCESS) {
      return allUsersResponse;
    }
    throw Exception({"statusCode": allUsersResponse.statusCode});
  }
}
