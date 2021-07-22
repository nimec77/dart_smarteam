class SmartRuntimeError extends Error {
  SmartRuntimeError(this.message) : super();

  final String message;

  @override
  String toString() => 'SmartRuntimeError: $message';
}
