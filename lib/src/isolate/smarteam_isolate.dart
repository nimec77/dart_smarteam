import 'dart:ffi';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:smarteam/smarteam.dart';
import 'package:smarteam/src/contants.dart';
import 'package:smarteam/src/function_names.dart';
import 'package:smarteam/src/isolate/isolate_result.dart';
import 'package:smarteam/src/isolate/isolate_task.dart';
import 'package:smarteam/src/isolate/worker.dart';

import '../helper.dart' as helper;
import '../types/types.dart';

final _functionsMap = <String, dynamic>{};

Future<void> isolateEntryPoint(IsolateParams params) async {
  final receivePort = ReceivePort();
  final sendPort = params.sendPort..send(receivePort.sendPort);

  await for (final task in receivePort.cast<IsolateTask>()) {
    try {
      final shouldPassParam = task.param != null;

      late dynamic result;

      if (task.functionName == kInit) {
        result = await init();
      }

      if (!_functionsMap.containsKey(task.functionName)) {
        throw ArgumentError("Function '${task.functionName} not found");
      }

      final fun = _functionsMap[task.functionName]!;

      result = shouldPassParam ? await fun(task.param) : await fun();

      sendPort.send(result);
    } on Error catch (error) {
      final remoteError = RemoteError(error.toString(), error.stackTrace.toString());
      final result = IsolateResult(result: remoteError, capability: task.capability);
      sendPort.send(result);
    } on Exception catch (exception) {
      final remoteError = RemoteError(exception.toString(), 'Stack trace not available');
      final result = IsolateResult(result: remoteError, capability: task.capability);
      sendPort.send(result);
    }
  }
}

Future<bool> init() async {
  if (_functionsMap.isNotEmpty) {
    return true;
  }
  final smarteamLib = DynamicLibrary.open(kSmarteamLibrary);
  final rightTestPointer = smarteamLib.lookup<NativeFunction<RightTest>>(kRightTest);
  _functionsMap[kRightTest] = rightTestPointer.asFunction<RightTest>();
  final leftTestPointer = smarteamLib.lookup<NativeFunction<LeftTest>>(kLeftTest);
  _functionsMap[kLeftTest] = leftTestPointer.asFunction<LeftTest>();

  return true;
}

Future<EitherBool> rightTest() async {
  final rightTestFn = _functionsMap[kRightTest] as RightTest;
  final eitherBool = rightTestFn().ref;
  if (eitherBool.isLeft != 0) {
    return Left(helper.errorFromType(eitherBool.left));
  }

  return Right(eitherBool.right != 0);
}

Future<EitherBool> leftTest() async {
  final leftTestFn = _functionsMap[kLeftTest] as LeftTest;
  final eitherBool = leftTestFn().ref;
  if (eitherBool.isLeft == 0) {
    return Left(SmarteamError('Left value expected, but right value returned'));
  }

  return Left(helper.errorFromType(eitherBool.left));
}
