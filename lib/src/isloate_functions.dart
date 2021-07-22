import 'dart:ffi';

import 'package:dartz/dartz.dart';

import 'contants.dart';
import 'function_names.dart';
import 'smarteam.dart';
import 'types/types.dart';

Future<EitherMap> smarteamInit() async {
  final smartFunctions = <String, dynamic>{};
  final smarteamLib = DynamicLibrary.open(kSmarteamLibrary);
  final rightTestPointer = smarteamLib.lookup<NativeFunction<RightTest>>(kRightTest);
  smartFunctions[kRightTest] = rightTestPointer.asFunction<RightTest>();
  final leftTestPointer = smarteamLib.lookup<NativeFunction<LeftTest>>(kLeftTest);
  smartFunctions[kLeftTest] = leftTestPointer.asFunction<LeftTest>();

  return Right(smartFunctions);
}