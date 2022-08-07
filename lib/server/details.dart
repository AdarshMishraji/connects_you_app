import 'package:connects_you/constants/statusCodes.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/models/room.dart';
import 'package:connects_you/server/server.dart';

class Details {
  const Details();

  Future<Response<Room>?> getRoom(String roomId) async {
    final detailResponse =
        await Server.instance.get(endpoint: '${Endpoints.ROOMS}/$roomId');
    if (detailResponse.statusCode == StatusCodes.SUCCESS) {
      final body = detailResponse.decodedBody as Map<String, dynamic>;
      if (body.containsKey('response') &&
          body['response'].containsKey('room')) {
        final room = body['response']['room'];
        return Response(
          code: body.get('code', detailResponse.statusCode)!,
          message: body.get('message', '')!,
          response: Room(
            roomId: room.get('roomId', '')!,
            roomLogo: room.get('roomLogo', '')!,
            roomName: room.get('roomName', '')!,
            roomDescription: room.get('roomDescription', '')!,
            roomType: room.get('roomType', '')!,
            createdByUserId: room.get('createdByUserId', '')!,
            createdAt: room.get('createdAt', '')!,
            updatedAt: room.get('updatedAt', '')!,
          ),
        );
      }
    }
    return null;
  }
}
