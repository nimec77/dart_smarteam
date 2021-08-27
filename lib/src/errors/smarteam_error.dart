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
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is SmarteamError && message == other.message;
  }
}
