extension DefaultIterable<Any> on Iterable<Any> {
  String toStringWithoutBrackets() {
    return join(', ');
  }
}
