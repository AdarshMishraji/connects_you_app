// ignore_for_file: constant_identifier_names

class StatusCodes {
  static const int SUCCESS = 200;
  static const int NO_UPDATE = 204;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  static const int NOT_FOUND = 404;
  static const int NOT_ACCEPTED = 406;
  static const int CONFLICT = 409;
  static const int INTERNAL_ERROR = 500;
}

class ResponseStatusEnum {
  static const String SUCCESS = "SUCCESS";
  static const String PARTIAL_DATA = "PARTIAL_DATA";
  static const String NO_DATA_ERROR = "NO_DATA_ERROR";
  static const String BAD_REQUEST_ERROR = "BAD_REQUEST_ERROR";
  static const String UNAUTHORIZED_ERROR = "UNAUTHORIZED_ERROR";
  static const String FORBIDDEN_ERROR = "FORBIDDEN_ERROR";
  static const String NOT_FOUND_ERROR = "NOT_FOUND_ERROR";
  static const String NOT_ACCEPTED_ERROR = "NOT_ACCEPTED_ERROR";
  static const String ALREADY_EXISTS_ERROR = "ALREADY_EXISTS_ERROR";
  static const String INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR";
}
