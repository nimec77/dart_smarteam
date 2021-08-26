import 'package:meta/meta.dart';

@immutable
class SmarteamError extends Error {
  SmarteamError(this.message) : super();

  final String message;

  @override
  String toString() => 'SmarteamError: $message';

  @override
  int get hashCode => message.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is SmarteamError && message == other.message;
  }
}
