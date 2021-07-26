import 'package:dartz/dartz.dart';
import 'package:smarteam/src/argumets/user_login_arg.dart';
import 'package:smarteam/src/function_names.dart';
import 'package:smarteam/src/isolate/isolate_compute.dart';
import 'types/types.dart';

class Smarteam {
  const Smarteam();

  static final _isolateCompute = IsolateCompute();

  Future<EitherBool> init() async {
    if (_isolateCompute.isRunning) {
      return const Right(true);
    }
    await _isolateCompute.turnOn();

    return _isolateCompute.compute<bool, bool>(kInit);
  }

  Future<void> dispose() async {
    if (!_isolateCompute.isRunning) {
      return;
    }

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
}
