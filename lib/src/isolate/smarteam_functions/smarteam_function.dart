import 'dart:ffi';

import 'package:dart_smarteam/src/argumets/user_login_arg.dart';
import 'package:dart_smarteam/src/contants.dart';
import 'package:dart_smarteam/src/errors/errors.dart';
import 'package:dart_smarteam/src/function_names.dart';
import 'package:dart_smarteam/src/helper.dart' as helper;
import 'package:dart_smarteam/src/types/types.dart';
import 'package:dartz/dartz.dart';
import 'package:ffi/ffi.dart';

part 'smart_user_function.dart';

part 'crypto_function.dart';

class SmarteamFunction {
  SmarteamFunction._();

  static final _smarteamFunctionsMap = <String, dynamic>{};

  final _libraryFunctionsMap = <String, dynamic>{};

  static void init() {
    final smarteamFunction = SmarteamFunction._();

    _smarteamFunctionsMap[kInit] = smarteamFunction.initSmarteam;
    _smarteamFunctionsMap[kRelease] = smarteamFunction.releaseSmarteam;
    _smarteamFunctionsMap[kRightTest] = smarteamFunction.rightTest;
    _smarteamFunctionsMap[kLeftTest] = smarteamFunction.leftTest;
    _smarteamFunctionsMap
      ..addAll(SmartUserFunction.mapSmartFunctions())
      ..addAll(CryptoFunction.mapSmartFunctions());
  }

  static Future<void> dispose() async {
    if (_smarteamFunctionsMap.isEmpty) {
      return;
    }
    try {
      await runFunction<EitherBool>(kRelease);
    } finally {
      _smarteamFunctionsMap.clear();
    }
  }

  static Future<dynamic> runFunction<P>(String functionName, {P? param}) async {
    if (!_smarteamFunctionsMap.containsKey(functionName)) {
      ArgumentError("Function '$functionName not found");
    }

    final dynamic fun = _smarteamFunctionsMap[functionName];

    return param == null ? await fun() : await fun(param);
  }

  Future<EitherBool> initSmarteam() async {
    if (_libraryFunctionsMap.isNotEmpty) {
      return const Right(true);
    }

    final smarteamLib = DynamicLibrary.open(kSmarteamLibrary);

    final initPointer = smarteamLib.lookup<NativeFunction<FnVoidBool>>(kInit);
    _libraryFunctionsMap[kInit] = initPointer.asFunction<FnVoidBool>();

    final closePointer = smarteamLib.lookup<NativeFunction<FnVoidBool>>(kRelease);
    _libraryFunctionsMap[kRelease] = closePointer.asFunction<FnVoidBool>();

    final rightTestPointer = smarteamLib.lookup<NativeFunction<FnVoidBool>>(kRightTest);
    _libraryFunctionsMap[kRightTest] = rightTestPointer.asFunction<FnVoidBool>();

    final leftTestPointer = smarteamLib.lookup<NativeFunction<FnVoidBool>>(kLeftTest);
    _libraryFunctionsMap[kLeftTest] = leftTestPointer.asFunction<FnVoidBool>();

    SmartUserFunction.initSmarteam(smarteamLib);
    CryptoFunction.initSmarteam(smarteamLib);

    final initFn = _libraryFunctionsMap[kInit] as FnVoidBool;
    final eitherBool = initFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> releaseSmarteam() async {
    final releaseFn = _libraryFunctionsMap[kRelease] as FnVoidBool;
    final eitherBool = releaseFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> rightTest() async {
    final rightTestFn = _libraryFunctionsMap[kRightTest] as FnVoidBool;
    final eitherBool = rightTestFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> leftTest() async {
    final leftTestFn = _libraryFunctionsMap[kLeftTest] as FnVoidBool;
    final eitherBool = leftTestFn().ref;
    if (eitherBool.isLeft == 0) {
      return Left(SmarteamError('Left value expected, but right value returned'));
    }

    return Left(helper.errorFromType(eitherBool.left));
  }
}
