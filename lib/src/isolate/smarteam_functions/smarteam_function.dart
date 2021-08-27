import 'dart:ffi';

import 'package:dart_smarteam/src/contants.dart';
import 'package:dart_smarteam/src/errors/errors.dart';
import 'package:dart_smarteam/src/function_names.dart';
import 'package:dart_smarteam/src/types/types.dart';
import 'package:dartz/dartz.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_smarteam/src/argumets/user_login_arg.dart';

import 'package:dart_smarteam/src/helper.dart' as helper;

class SmarteamFunction {
  static final _smarteamFunctionsMap = <String, dynamic>{};
  
  final _libraryFunctionsMap = <String, dynamic>{};

  static void init() {
    final smarteamFunction = SmarteamFunction();

    _smarteamFunctionsMap[kInit] = smarteamFunction.initSmarteam;
    _smarteamFunctionsMap[kRelease] = smarteamFunction.releaseSmarteam;
    _smarteamFunctionsMap[kRightTest] = smarteamFunction.rightTest;
    _smarteamFunctionsMap[kLeftTest] = smarteamFunction.leftTest;
    _smarteamFunctionsMap[kUserLogoff] = smarteamFunction.userLogoff;
    _smarteamFunctionsMap[kUserLogin] = smarteamFunction.userLogin;
  }

  static Future<void> dispose() async {
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

    final userLogoffPointer = smarteamLib.lookup<NativeFunction<FnVoidBool>>(kUserLogoff);
    _libraryFunctionsMap[kUserLogoff] = userLogoffPointer.asFunction<FnVoidBool>();

    final userLoginPointer = smarteamLib.lookup<NativeFunction<FnStrStrBool>>(kUserLogin);
    _libraryFunctionsMap[kUserLogin] = userLoginPointer.asFunction<FnStrStrBool>();

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

  Future<EitherBool> userLogoff() async {
    final userLogoffFn = _libraryFunctionsMap[kUserLogoff] as FnVoidBool;
    final eitherBool = userLogoffFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> userLogin(UserLoginArg userLoginArg) async {
    final userLoginFn = _libraryFunctionsMap[kUserLogin] as FnStrStrBool;
    final usernameNative = userLoginArg.username.toNativeUtf16();
    final passwordNative = userLoginArg.password.toNativeUtf16();
    final eitherBool = userLoginFn(usernameNative, passwordNative).ref;
    malloc..free(usernameNative)..free(passwordNative);
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }
}
