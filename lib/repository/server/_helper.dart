import 'package:connects_you/constants/response_status.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:http_wrapper/http.dart';

class _Response {
  final String status;
  final Map<String, dynamic> data;

  const _Response({
    required this.data,
    required this.status,
  });
}

_Response getDecodedDataFromResponse(DecodedResponse? response) {
  final body = response != null
      ? response.decodedBody as Map<String, dynamic>
      : <String, dynamic>{};

  if (isEmptyEntity(body)) throw Exception("No response");

  final Map<String, dynamic> data = body.get('data', {});
  final String status = body.get('status', ResponseStatusEnum.SUCCESS);

  return _Response(data: data, status: status);
}
