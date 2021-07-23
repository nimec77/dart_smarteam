import 'package:dartz/dartz.dart';
import 'package:smarteam/src/function_names.dart';
import 'package:smarteam/src/isolate/isolate_compute.dart';
import 'types/types.dart';

class Smarteam {
  const Smarteam();

  static final _isolateCompute = IsolateCompute();

  Future<EitherBool> init() async {
    await _isolateCompute.turnOn();

    return _isolateCompute.compute<bool, bool>(kInit);
  }

// EitherBool rightTest() {
//   final rightTestFn = _smartFunctions[kRightTest] as RightTest;
//   final eitherBool = rightTestFn().ref;
//   if (eitherBool.isLeft != 0) {
//     return Left(helper.errorFromType(eitherBool.left));
//   }
//
//   return Right(eitherBool.right != 0);
// }
//
// EitherBool leftTest() {
//   final leftTestFn = _smartFunctions[kLeftTest] as LeftTest;
//   final eitherBool = leftTestFn().ref;
//   if (eitherBool.isLeft == 0) {
//     return Left(SmarteamError('Left value expected, but right value returned'));
//   }
//
//   return Left(helper.errorFromType(eitherBool.left));
// }

// @override
// int get hashCode => _smartFunctions.hashCode;
//
// @override
// bool operator ==(Object other) {
//   return identical(this, other);
// }
}
