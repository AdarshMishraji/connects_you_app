import 'dart:convert';

import 'package:http/http.dart' as http;

class DecodedResponse extends http.Response {
  final dynamic decodedBody;

  static dynamic _jsonDecodeWrapper(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return jsonString;
    }
  }

  DecodedResponse(http.Response res)
      : decodedBody = DecodedResponse._jsonDecodeWrapper(res.body),
        super(
          res.body,
          res.statusCode,
          request: res.request,
          headers: res.headers,
          isRedirect: res.isRedirect,
          persistentConnection: res.persistentConnection,
          reasonPhrase: res.reasonPhrase,
        );

  @override
  String toString() {
    return body;
  }
}

///* Throws error when there is statusCode >= 400;
///* the error body is itself the DecodedResponse and can be used to do further things;
///* use res.decodedBody instead of res.body;
class Http {
  final String baseURL;
  final Map<String, String>? headers;
  final bool shouldThrowError;

  const Http(
      {required this.baseURL, this.headers, this.shouldThrowError = true});

  static get defaultGet {
    return http.get;
  }

  static get defaultHead {
    return http.head;
  }

  static get defaultPost {
    return http.post;
  }

  static get defaultPut {
    return http.put;
  }

  static get defaultPatch {
    return http.patch;
  }

  static get defaultDelete {
    return http.delete;
  }

  static get defaultRead {
    return http.read;
  }

  DecodedResponse _parseAndHandleErrors(http.Response res) {
    if (res.statusCode < 400) {
      return DecodedResponse(res);
    } else {
      if (shouldThrowError) {
        throw DecodedResponse(res);
      } else {
        return DecodedResponse(res);
      }
    }
  }

  Future<DecodedResponse> get({
    String? endpoint,
    Map<String, String>? headers,
  }) {
    return http
        .get(Uri.parse(baseURL + (endpoint ?? '')),
            headers: (headers == null) ? this.headers : headers
              ?..addAll(this.headers ?? {}))
        .then(_parseAndHandleErrors);
  }

  Future<DecodedResponse> post({
    String? endpoint,
    String? body,
    Map<String, String>? headers,
  }) {
    return http
        .post(Uri.parse(baseURL + (endpoint ?? '')),
            body: body,
            headers: (headers == null) ? this.headers : headers
              ?..addAll(this.headers ?? {}))
        .then(_parseAndHandleErrors);
  }

  Future<DecodedResponse> put({
    String? endpoint,
    String? body,
    Map<String, String>? headers,
  }) {
    return http
        .put(Uri.parse(baseURL + (endpoint ?? '')),
            body: body,
            headers: (headers == null) ? this.headers : headers
              ?..addAll(this.headers ?? {}))
        .then(_parseAndHandleErrors);
  }

  Future<DecodedResponse> patch({
    String? endpoint,
    String? body,
    Map<String, String>? headers,
  }) {
    return http
        .patch(Uri.parse(baseURL + (endpoint ?? '')),
            body: body,
            headers: (headers == null) ? this.headers : headers
              ?..addAll(this.headers ?? {}))
        .then(_parseAndHandleErrors);
  }

  Future<DecodedResponse> delete({
    String? endpoint,
    String? body,
    Map<String, String>? headers,
  }) {
    return http
        .delete(Uri.parse(baseURL + (endpoint ?? '')),
            body: body,
            headers: (headers == null) ? this.headers : headers
              ?..addAll(this.headers ?? {}))
        .then(_parseAndHandleErrors);
  }

  Future<DecodedResponse> head({
    String? endpoint,
    Map<String, String>? headers,
  }) {
    return http
        .head(Uri.parse(baseURL + (endpoint ?? '')),
            headers: (headers == null) ? this.headers : headers
              ?..addAll(this.headers ?? {}))
        .then(_parseAndHandleErrors);
  }
}
