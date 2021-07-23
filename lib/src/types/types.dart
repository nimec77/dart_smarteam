
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:smarteam/src/pods/either_bool_pod.dart';

typedef FunctionsMap = Map<String, dynamic>;

typedef EitherBool = Either<Error, bool>;

typedef EitherMap = Either<Error, Map<String, dynamic>>;

typedef FnBoolVoid = Pointer<EitherBoolPod> Function();
