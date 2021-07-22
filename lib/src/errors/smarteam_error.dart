class SmarteamError extends Error {
  SmarteamError(this.message) : super();

  final String message;

  @override
  String toString() => 'SmarteamError: $message';
}