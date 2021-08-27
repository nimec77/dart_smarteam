part of 'smarteam_function.dart';

class SmartUserFunction {
  SmartUserFunction._();

  static final _libraryFunctionsMap = <String, dynamic>{};

  static Map<String, dynamic> mapSmartUserFunctions() {
    final smartUserFunction = SmartUserFunction._();
    final functions = <String, dynamic>{};

    functions[kUserLogoff] = smartUserFunction.userLogoff;
    functions[kUserLogin] = smartUserFunction.userLogin;

    return functions;
  }

  static void initSmarteam(DynamicLibrary smarteamLib) {
    if (_libraryFunctionsMap.isNotEmpty) {
      return;
    }

    final userLogoffPointer = smarteamLib.lookup<NativeFunction<FnVoidBool>>(kUserLogoff);
    _libraryFunctionsMap[kUserLogoff] = userLogoffPointer.asFunction<FnVoidBool>();

    final userLoginPointer = smarteamLib.lookup<NativeFunction<FnStrStrBool>>(kUserLogin);
    _libraryFunctionsMap[kUserLogin] = userLoginPointer.asFunction<FnStrStrBool>();
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