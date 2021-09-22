
import 'dart:ffi';

import 'package:dart_smarteam/src/pods/either_bool_pod.dart';
import 'package:dart_smarteam/src/pods/either_string_pod.dart';
import 'package:dartz/dartz.dart';
import 'package:ffi/ffi.dart';

typedef FunctionsMap = Map<String, dynamic>;

typedef EitherBool = Either<Error, bool>;

typedef EitherMap = Either<Error, Map<String, dynamic>>;

typedef EitherString = Either<Error, String>;

typedef FnVoidBool = Pointer<EitherBoolPod> Function();

typedef FnVoidStr = Pointer<EitherStringPod> Function();

typedef FnStrStr = Pointer<EitherStringPod> Function(Pointer<Utf16> str);

typedef FnStrStrBool = Pointer<EitherBoolPod> Function(Pointer<Utf16> str1, Pointer<Utf16> str2);
