import 'package:connects_you/constants/keys.dart';
import 'package:connects_you/constants/url.dart';
import 'package:http_wrapper/http.dart';

class Response<T> {
  final int code;
  final String status;
  final T response;

  const Response({
    required this.code,
    required this.status,
    required this.response,
  });
}

class Server extends Http {
  Server._()
      : super(
          baseURL: URLs.baseURL,
          headers: {
            'api-key': Keys.API_KEY,
            "Content-Type": "application/json",
          },
        );

  static final Server _instance = Server._();

  factory Server() {
    return _instance;
  }
}
