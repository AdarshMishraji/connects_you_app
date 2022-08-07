class CustomException {
  final String errorMessage;

  const CustomException({required this.errorMessage});

  @override
  String toString() {
    return errorMessage;
  }
}
