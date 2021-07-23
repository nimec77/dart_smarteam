import 'dart:isolate';

class IsolateTask<P> {
  const IsolateTask({
    required this.functionName,
    required this.param,
    required this.capability,
  });

  final String functionName;
  final P param;

  final Capability capability;
}
