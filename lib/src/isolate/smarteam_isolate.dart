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

class SmarteamIsolate {
  static final _libraryFunctionsMap = <String, dynamic>{};
  static final _smarteamFunctionsMap = <String, dynamic>{};

  static Future<void> isolateEntryPoint(IsolateParams params) async {
    final receivePort = ReceivePort();
    final sendPort = params.sendPort..send(receivePort.sendPort);

    mapSmarteamFunctions();

    await for (final task in receivePort.cast<IsolateTask>()) {
      try {
        final computationResult = await runFunction(task.functionName, param: task.param);

        final result = IsolateResult(
          result: computationResult,
          capability: task.capability,
        );

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

  static void mapSmarteamFunctions() {
    final smarteamIsolate = SmarteamIsolate();

    _smarteamFunctionsMap[kInit] = smarteamIsolate.init;
    _smarteamFunctionsMap[kRightTest] = smarteamIsolate.rightTest;
    _smarteamFunctionsMap[kLeftTest] = smarteamIsolate.leftTest;
  }

  static Future<dynamic> runFunction<P>(String functionName, {P? param}) async {
    if (!_smarteamFunctionsMap.containsKey(functionName)) {
      ArgumentError("Function '$functionName not found");
    }

    final fun = _smarteamFunctionsMap[functionName];

    return param == null ? await fun() : await fun(param);
  }

  Future<EitherBool> init() async {
    if (_libraryFunctionsMap.isNotEmpty) {
      return const Right(true);
    }
    final smarteamLib = DynamicLibrary.open(kSmarteamLibrary);

    final initPointer = smarteamLib.lookup<NativeFunction<FnBoolVoid>>(kInit);
    _libraryFunctionsMap[kInit] = initPointer.asFunction<FnBoolVoid>();

    final rightTestPointer = smarteamLib.lookup<NativeFunction<FnBoolVoid>>(kRightTest);
    _libraryFunctionsMap[kRightTest] = rightTestPointer.asFunction<FnBoolVoid>();

    final leftTestPointer = smarteamLib.lookup<NativeFunction<FnBoolVoid>>(kLeftTest);
    _libraryFunctionsMap[kLeftTest] = leftTestPointer.asFunction<FnBoolVoid>();

    final initFn = _libraryFunctionsMap[kInit] as FnBoolVoid;
    final eitherBool = initFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> rightTest() async {
    final rightTestFn = _libraryFunctionsMap[kRightTest] as FnBoolVoid;
    final eitherBool = rightTestFn().ref;
    if (eitherBool.isLeft != 0) {
      return Left(helper.errorFromType(eitherBool.left));
    }

    return Right(eitherBool.right != 0);
  }

  Future<EitherBool> leftTest() async {
    final leftTestFn = _libraryFunctionsMap[kLeftTest] as FnBoolVoid;
    final eitherBool = leftTestFn().ref;
    if (eitherBool.isLeft == 0) {
      return Left(SmarteamError('Left value expected, but right value returned'));
    }

    return Left(helper.errorFromType(eitherBool.left));
  }
}
