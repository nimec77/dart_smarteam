import 'dart:isolate';

class IsolateResult {
  const IsolateResult({required this.result, required this.capability});

  final dynamic result;
  final Capability capability;
}
