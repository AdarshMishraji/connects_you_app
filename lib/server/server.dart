// ignore_for_file: constant_identifier_names

import 'package:connects_you/constants/keys.dart';
import 'package:connects_you/server/auth.dart';
import 'package:connects_you/server/details.dart';
import 'package:connects_you/server/me.dart';
import 'package:connects_you/server/users.dart';
import 'package:http_wrapper/http.dart';

class Endpoints {
  static const String _AUTH = '/auth';
  static const String _DETAILS = '/details';
  static const String ME = '/me';
  static const String AUTHENTICATE = '${Endpoints._AUTH}/authenticate';
  static const String REFRESH_TOKEN = '${Endpoints._AUTH}/refresh_token';
  static const String SIGNOUT = '${Endpoints._AUTH}/signout';
  static const String ROOMS = '${Endpoints._DETAILS}/rooms';
  static const String CACHED_DATA = '${Endpoints.ME}/cached_data';
  static const String USERS = '/users';
}

class Response<T> {
  final int code;
  final String message;
  final T response;

  const Response({
    required this.code,
    required this.message,
    required this.response,
  });
}

class Server extends Http {
  Server._()
      : super(
          // baseURL: 'https://57e8eac4fbdefa.lhrtunnel.link',
          baseURL: "http://10.0.2.2:4000",
          headers: {
            'api-key': Keys.API_KEY,
            "Content-Type": "application/json",
          },
        );

  static final Server _instance = Server._();

  static Server get instance {
    return _instance;
  }

  static const Auth AuthOps = Auth();
  static const Details DetailsOps = Details();
  static const Me MeOps = Me();
  static const Users UsersOps = Users();
}
