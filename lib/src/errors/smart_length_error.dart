class SmartLengthError extends Error {
  SmartLengthError(this.message) : super();

  final String message;

  @override
  String toString() => 'SmartLengthError: $message';
}
