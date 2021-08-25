import 'dart:ffi';

import 'package:dart_smarteam/src/pods/exception_pod.dart';

class EitherBoolPod extends Struct {
  @Int8()
  external int isLeft;

  external ExceptionPod left;

  @Int8()
  external int right;
}
