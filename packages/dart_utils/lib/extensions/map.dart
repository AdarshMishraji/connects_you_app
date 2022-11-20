import 'package:dart_utils/extensions/iterable.dart';

extension DefaultMap<Key, Value> on Map<String, dynamic> {
  Value? get(Key key, [Value? defaultValue]) {
    return containsKey(key) ? this[key] ?? defaultValue : defaultValue;
  }

  Map removeNulls() => removeNullsFromMap(this);

  Map<String, dynamic> toStringValues() {
    return map((key, value) => MapEntry(key, value.toString()));
  }
}

Map<String, dynamic> removeNullsFromMap(Map<String, dynamic> map) {
  final mapToSend = <String, dynamic>{};

  for (final key in map.keys) {
    final value = map[key];
    if (value != null) {
      mapToSend[key] = value is Map<String, dynamic>
          ? removeNullsFromMap(value)
          : value is Iterable
              ? value.removeNulls()
              : value;
    }
  }

  return mapToSend;
}
