import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:smart_compute/smart_compute.dart';
import 'package:smarteam/src/errors/smarteam_error.dart';
import 'package:smarteam/src/function_names.dart';
import 'package:smarteam/src/pods/either_bool_pod.dart';

import 'helper.dart' as helper;
import 'isloate_functions.dart' as fun;
import 'types/types.dart';

typedef RightTest = Pointer<EitherBoolPod> Function();
typedef LeftTest = Pointer<EitherBoolPod> Function();

class Smarteam {
  const Smarteam();

  static final _smartCompute = SmartCompute();
  static final _smartFunctions = <String, dynamic>{};

  Future<EitherBool> init() async {
    try {
      if (_smartCompute.isRunning) {
        return const Right(true);
      }
      await _smartCompute.turnOn();
      final result = await _smartCompute.compute<FunctionsMap, FunctionsMap>(fun.smarteamInit);
      print(result);
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

