import 'package:dart_smarteam/smarteam.dart';

class SmartRuntimeError extends SmarteamError {
  SmartRuntimeError(String message) : super(message);

  @override
  String toString() => 'SmartRuntimeError: $message';
}
