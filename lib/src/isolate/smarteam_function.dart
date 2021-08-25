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
  final _libraryFunctionsMap = <String, dynamic>{};

  Future<EitherBool> init() async {
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

  Future<EitherBool> release() async {
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
