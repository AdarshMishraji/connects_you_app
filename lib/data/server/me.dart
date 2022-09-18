import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/data/server/server.dart';
import 'package:http_wrapper/http.dart';

class MeDataSource {
  const MeDataSource._();
  static const _instance = MeDataSource._();
  static const instance = _instance;

  Future<DecodedResponse?> getAuthUser(String token) async {
    final authUserResponse = await Server.instance
        .get(endpoint: Endpoints.ME, headers: {'token': token});
    if (authUserResponse.statusCode == StatusCodes.SUCCESS) {
      return authUserResponse;
    }
    return null;
  }

  Future<DecodedResponse?> getCachedData(String token,
      [bool shouldSaveToLocalDB = true]) async {
    final cachedDataResponse = await Server.instance
        .get(endpoint: Endpoints.CACHED_DATA, headers: {'token': token});
    if (cachedDataResponse.statusCode == StatusCodes.SUCCESS) {
      return cachedDataResponse;
    }
    return null;
  }
}
