library dart_utils;

export './extensions/iterable.dart';
export './extensions/map.dart';
export './extensions/string.dart';

String createQueryUrl(String url, Map<String, String> queries) {
  final uri = Uri.parse(url);
  final queryParameters = Map<String, dynamic>.from(uri.queryParameters);
  queryParameters.addAll(queries);
  return uri.replace(queryParameters: queryParameters).toString();
}

bool isEmptyEntity(dynamic entity) {
  return entity == null ||
      (entity is String ? entity.isEmpty : false) ||
      (entity is List<dynamic> ? entity.isEmpty : false) ||
      (entity is Map<String, dynamic> ? entity.isEmpty : false);
}
