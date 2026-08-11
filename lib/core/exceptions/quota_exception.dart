class QuotaExceededException implements Exception {
  final String message;
  const QuotaExceededException(this.message);

  @override
  String toString() => message;
}
