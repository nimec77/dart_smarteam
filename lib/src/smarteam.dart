import 'package:dart_smarteam/src/argumets/user_login_arg.dart';
import 'package:dart_smarteam/src/function_names.dart';
import 'package:dart_smarteam/src/isolate/isolate_compute.dart';
import 'package:dart_smarteam/src/types/types.dart';

class Smarteam {
  const Smarteam();

  static final _isolateCompute = IsolateCompute();

  Future<EitherBool> init() async {
    if (!_isolateCompute.isRunning) {
      await _isolateCompute.turnOn();
    }

    return _isolateCompute.compute<bool, bool>(kInit);
  }

  Future<void> dispose() async {
    if (!_isolateCompute.isRunning) {
      return;
    }

    await _isolateCompute.compute<void, bool>(kRelease);

    await _isolateCompute.turnOff();
  }

  Future<EitherBool> rightTest() async {
    return _isolateCompute.compute<void, bool>(kRightTest);
  }

  Future<EitherBool> leftTest() async {
    return _isolateCompute.compute<void, bool>(kLeftTest);
  }

  Future<EitherBool> userLogoff() async {
    return _isolateCompute.compute<void, bool>(kUserLogoff);
  }

  Future<EitherBool> userLogin(String username, String password) async {
    return _isolateCompute.compute<UserLoginArg, bool>(kUserLogin, param: UserLoginArg(username, password));
  }

  Future<EitherString> getSid() async {
    return _isolateCompute.compute<void, String>(kGetSid);
  }

  Future<EitherString> encode(String text) async {
    return _isolateCompute.compute<String, String>(kEncode, param: text);
  }

  Future<EitherString> decode(String hexText) async {
    return _isolateCompute.compute<String, String>(kDecode, param: hexText);
  }
}
