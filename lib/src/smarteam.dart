import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:smarteam/src/contants.dart';
import 'package:smarteam/src/errors/smarteam_error.dart';
import 'package:smarteam/src/function_names.dart';
import 'package:smarteam/src/pods/either_bool_pod.dart';

import 'helper.dart' as helper;
import 'types/types.dart';

typedef RightTest = Pointer<EitherBoolPod> Function();
typedef LeftTest = Pointer<EitherBoolPod> Function();

class Smarteam {
  const Smarteam();

  static final _smartFunctions = <String, dynamic>{};

  EitherBool init() {
    try {
      if (_smartFunctions.isNotEmpty) {
        return const Right(true);
      }
      final smarteamLib = DynamicLibrary.open(kSmarteamLibrary);
      final rightTestPointer = smarteamLib.lookup<NativeFunction<RightTest>>(kRightTest);
      _smartFunctions[kRightTest] = rightTestPointer.asFunction<RightTest>();
      final leftTestPointer = smarteamLib.lookup<NativeFunction<LeftTest>>(kLeftTest);
      _smartFunctions[kLeftTest] = leftTestPointer.asFunction<LeftTest>();
    } on ArgumentError catch (error) {
      return Left(error);
    }

    return const Right(true);
  }

  EitherBool rightTest() {
    final rightTestFn = _smartFunctions[kRightTest] as RightTest;
    final eitherBool = rightTestFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  EitherBool leftTest() {
    final leftTestFn = _smartFunctions[kLeftTest] as LeftTest;
    final eitherBool = leftTestFn().ref;
    if (eitherBool.isLeft == 0) {
      return Left(SmarteamError('Left value expected, but right value returned'));
    }

    return Left(helper.errorFromType(eitherBool.left));
  }

  @override
  int get hashCode => _smartFunctions.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }
}
