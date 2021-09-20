import 'package:dart_smarteam/src/isolate/isolate_api.dart';
import 'package:dartz/dartz.dart';

class IsolateCompute {
  factory IsolateCompute() => _singleton;

  IsolateCompute._();

  static final _singleton = IsolateCompute._();

  final _isolateDelegate = IsolateAPI();

  bool get isRunning => _isolateDelegate.isRunning;

  Future<void> turnOn() async {
    return _isolateDelegate.turnOn();
  }

  Future<Either<Error, R>> compute<P, R>(String functionName, {P? param}) async {
    return _isolateDelegate.compute<P, R>(functionName, param: param);
  }

  Future<void> turnOff() async {
    return _isolateDelegate.turnOff();
  }
}
