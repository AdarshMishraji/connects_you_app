extension DefaultString on String {
  int? tryParseInt() {
    return int.tryParse(this);
  }

  double? tryParseDouble() {
    return double.tryParse(this);
  }
}
