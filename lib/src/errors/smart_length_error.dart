import 'package:dart_smarteam/smarteam.dart';

class SmartLengthError extends SmarteamError {
  SmartLengthError(String message) : super(message);

  @override
  String toString() => 'SmartLengthError: $message';
}
