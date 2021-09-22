part of 'smarteam_function.dart';

class CryptoFunction {
  CryptoFunction._();

  static final _libraryFunctionsMap = <String, dynamic>{};

  static Map<String, dynamic> mapSmartFunctions() {
    final functions = <String, dynamic>{};
    final cryptoFunction = CryptoFunction._();

    functions[kGetSid] = cryptoFunction.getSid;
    functions[kEncode] = cryptoFunction.encode;
    functions[kDecode] = cryptoFunction.decode;

    return functions;
  }

  static void initSmarteam(DynamicLibrary smarteamLib) {
    if (_libraryFunctionsMap.isNotEmpty) {
      return;
    }

    final getSidPointer = smarteamLib.lookup<NativeFunction<FnVoidStr>>(kGetSid);
    _libraryFunctionsMap[kGetSid] = getSidPointer.asFunction<FnVoidStr>();

    final encodePointer = smarteamLib.lookup<NativeFunction<FnStrStr>>(kEncode);
    _libraryFunctionsMap[kEncode] = encodePointer.asFunction<FnStrStr>();

    final decodePointer = smarteamLib.lookup<NativeFunction<FnStrStr>>(kDecode);
    _libraryFunctionsMap[kDecode] = decodePointer.asFunction<FnStrStr>();
  }

  Future<EitherString> getSid() async {
    final getSidFn = _libraryFunctionsMap[kGetSid] as FnVoidStr;
    final eitherString = getSidFn().ref;
    if (eitherString.isLeft != 0) {
      return Left(helper.errorFromType(eitherString.left));
    }
    return Right(eitherString.right.toDartString());
  }

  Future<EitherString> encode(String text) async {
    final encodeFn = _libraryFunctionsMap[kEncode] as FnStrStr;
    final textNative = text.toNativeUtf16();
    final eitherString = encodeFn(textNative).ref;
    malloc.free(textNative);
    if (eitherString.isLeft != 0) {
      return Left(helper.errorFromType(eitherString.left));
    }

    return Right(eitherString.right.toDartString());
  }

  Future<EitherString> decode(String hexText) async {
    final decodeFn = _libraryFunctionsMap[kDecode] as FnStrStr;
    final hexTextNative = hexText.toNativeUtf16();
    final eitherString = decodeFn(hexTextNative).ref;
    malloc.free(hexTextNative);

    if (eitherString.isLeft != 0) {
      return Left(helper.errorFromType(eitherString.left));
    }

    return Right(eitherString.right.toDartString());
  }
}