
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:ffi/ffi.dart';
import 'package:smarteam/src/pods/either_bool_pod.dart';

typedef FunctionsMap = Map<String, dynamic>;

typedef EitherBool = Either<Error, bool>;

typedef EitherMap = Either<Error, Map<String, dynamic>>;

typedef FnVoidBool = Pointer<EitherBoolPod> Function();

typedef FnStrStrBool = Pointer<EitherBoolPod> Function(Pointer<Utf16> str1, Pointer<Utf16> str2);
