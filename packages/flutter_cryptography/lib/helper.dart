String toHex(List<int> bytes) {
  return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
}

List<int> fromHex(String s) {
  return List<int>.generate(s.length ~/ 2, (i) {
    var byteInHex = s.substring(2 * i, 2 * i + 2);
    if (byteInHex.startsWith('0')) {
      byteInHex = byteInHex.substring(1);
    }
    final result = int.tryParse(byteInHex, radix: 16);
    if (result == null) {
      throw StateError('Not valid hexadecimal bytes: $s');
    }
    return result;
  });
}
