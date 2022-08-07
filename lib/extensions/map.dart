import 'dart:developer';

extension DefaultMap<Key, Value> on Map<Key, Value> {
  Value? get(Key key, [Value? defaultValue]) {
    log('key to check get, $key ${this[key]} $defaultValue');
    return containsKey(key) ? this[key] ?? defaultValue : defaultValue;
  }
}
