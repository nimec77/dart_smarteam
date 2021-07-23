import 'dart:ffi';

import 'package:dartz/dartz.dart';

import '../../smarteam.dart';
import '../contants.dart';
import '../function_names.dart';
import '../helper.dart' as helper;

class SmarteamFunction {
  final _libraryFunctionsMap = <String, dynamic>{};

  Future<EitherBool> init() async {
    if (_libraryFunctionsMap.isNotEmpty) {
      return const Right(true);
    }

    final smarteamLib = DynamicLibrary.open(kSmarteamLibrary);

    final initPointer = smarteamLib.lookup<NativeFunction<FnBoolVoid>>(kInit);
    _libraryFunctionsMap[kInit] = initPointer.asFunction<FnBoolVoid>();

    final rightTestPointer = smarteamLib.lookup<NativeFunction<FnBoolVoid>>(kRightTest);
    _libraryFunctionsMap[kRightTest] = rightTestPointer.asFunction<FnBoolVoid>();

    final leftTestPointer = smarteamLib.lookup<NativeFunction<FnBoolVoid>>(kLeftTest);
    _libraryFunctionsMap[kLeftTest] = leftTestPointer.asFunction<FnBoolVoid>();

    final initFn = _libraryFunctionsMap[kInit] as FnBoolVoid;
    final eitherBool = initFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> rightTest() async {
    final rightTestFn = _libraryFunctionsMap[kRightTest] as FnBoolVoid;
    final eitherBool = rightTestFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> leftTest() async {
    final leftTestFn = _libraryFunctionsMap[kLeftTest] as FnBoolVoid;
    final eitherBool = leftTestFn().ref;
    if (eitherBool.isLeft == 0) {
      return Left(SmarteamError('Left value expected, but right value returned'));
    }

    return Left(helper.errorFromType(eitherBool.left));
  }

}