class DocumentFormatException implements Exception {
  final String message;
  DocumentFormatException(this.message);

  @override
  String toString() => 'DocumentFormatException: $message';
}