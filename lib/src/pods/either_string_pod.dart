import 'dart:ffi';

import 'package:dart_smarteam/src/pods/exception_pod.dart';
import 'package:ffi/ffi.dart';

class EitherStringPod extends Struct {
  @Int8()
  external int isLeft;

  external ExceptionPod left;

  external Pointer<Utf8> right;
}