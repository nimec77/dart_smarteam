import 'package:dart_smarteam/src/errors/errors.dart';
import 'package:dart_smarteam/src/pods/exception_pod.dart';
import 'package:dart_smarteam/src/types/exception_type.dart';
import 'package:ffi/ffi.dart';

Error errorFromType(ExceptionPod exceptionPod) {
  final exceptionType = ExceptionType.values[exceptionPod.exceptionType];

  switch (exceptionType) {
    case ExceptionType.exception:
      return SmarteamError(exceptionPod.message.toDartString());

    case ExceptionType.invalidArgument:
      return ArgumentError(exceptionPod.message.toDartString());

    case ExceptionType.lengthError:
      return SmartLengthError(exceptionPod.message.toDartString());

    case ExceptionType.runtimeError:
      return SmartRuntimeError(exceptionPod.message.toDartString());

    default:
      return UnimplementedError(exceptionPod.message.toDartString());
  }
}
