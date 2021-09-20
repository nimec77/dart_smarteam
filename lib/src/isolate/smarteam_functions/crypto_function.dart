part of 'smarteam_function.dart';

class CryptoFunction {
  CryptoFunction._();

  static final _libraryFunctionsMap = <String, dynamic>{};

  static Map<String, dynamic> mapSmartFunctions() {
    final functions = <String, dynamic>{};
    final cryptoFunction = CryptoFunction._();

    functions[kEncode] = cryptoFunction.encode;
    functions[kDecode] = cryptoFunction.decode;

    return functions;
  }

  static void initSmarteam(DynamicLibrary smarteamLib) {
    if (_libraryFunctionsMap.isNotEmpty) {
      return;
    }

    final encodePointer = smarteamLib.lookup<NativeFunction<FnStrStr>>(kEncode);
    _libraryFunctionsMap[kEncode] = encodePointer.asFunction<FnStrStr>();

    final decodePointer = smarteamLib.lookup<NativeFunction<FnStrStr>>(kDecode);
    _libraryFunctionsMap[kDecode] = decodePointer.asFunction<FnStrStr>();
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