import 'package:dart_utils/extensions/map.dart';

extension DefaultIterable<Any> on Iterable<Any> {
  String toStringWithoutBrackets() {
    return join(', ');
  }

  Iterable removeNulls() => removeNullsFromIterable(this);

  Iterable toStringElements() {
    return map((element) => element.toString());
  }
}

Iterable removeNullsFromIterable(Iterable iterable) {
  final iterableToSend = <dynamic>[];

  for (final element in iterable) {
    if (element != null) {
      iterableToSend.add(element is Iterable
          ? removeNullsFromIterable(element)
          : element is Map<String, dynamic>
              ? element.removeNulls()
              : element);
    }
  }

  return iterableToSend;
}
