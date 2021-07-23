
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:smarteam/src/pods/either_bool_pod.dart';

typedef FunctionsMap = Map<String, dynamic>;

typedef EitherBool = Either<Error, bool>;

typedef EitherMap = Either<Error, Map<String, dynamic>>;

typedef RightTest = Pointer<EitherBoolPod> Function();

typedef LeftTest = Pointer<EitherBoolPod> Function();
