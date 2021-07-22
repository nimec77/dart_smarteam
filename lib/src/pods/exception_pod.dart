import 'dart:ffi';

import 'package:ffi/ffi.dart';

class ExceptionPod extends Struct {
  @Int32()
  external int exceptionType;

  external Pointer<Utf8> message;
}