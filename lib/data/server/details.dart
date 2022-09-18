import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:http_wrapper/http.dart';

class DetailsDataSource {
  const DetailsDataSource._();
  static const _instance = DetailsDataSource._();
  static const instance = _instance;

  Future<DecodedResponse?> getRoom(String roomId) async {
    final detailResponse =
        await Server.instance.get(endpoint: '${Endpoints.ROOMS}/$roomId');
    if (detailResponse.statusCode == StatusCodes.SUCCESS) {
      return detailResponse;
    }
    throw Exception({"statusCode": detailResponse.statusCode});
  }

  Future<DecodedResponse?> getUser(String userId) async {
    final userResponse =
        await Server.instance.get(endpoint: '${Endpoints.USERS}/$userId');
    if (userResponse.statusCode == StatusCodes.SUCCESS) {
      return userResponse;
    }
    throw Exception({"statusCode": userResponse.statusCode});
  }

  Future<DecodedResponse?> getAllUsers(String token,
      [int pageSize = 10, int skip = 0]) async {
    final allUserResponse = await Server.instance
        .get(endpoint: Endpoints.USERS, headers: {'token': token});
    if (allUserResponse.statusCode == StatusCodes.SUCCESS) {
      return allUserResponse;
    }
    throw Exception({"statusCode": allUserResponse.statusCode});
  }
}
