import 'dart:isolate';

import 'package:smarteam/src/function_names.dart';
import 'package:smarteam/src/isolate/isolate_result.dart';
import 'package:smarteam/src/isolate/isolate_task.dart';
import 'package:smarteam/src/isolate/smarteam_function.dart';
import 'package:smarteam/src/isolate/worker.dart';

class SmarteamIsolate {
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
    final smarteamFunction = SmarteamFunction();

    _smarteamFunctionsMap[kInit] = smarteamFunction.init;
    _smarteamFunctionsMap[kRightTest] = smarteamFunction.rightTest;
    _smarteamFunctionsMap[kLeftTest] = smarteamFunction.leftTest;
  }

  static Future<dynamic> runFunction<P>(String functionName, {P? param}) async {
    if (!_smarteamFunctionsMap.containsKey(functionName)) {
      ArgumentError("Function '$functionName not found");
    }

    final fun = _smarteamFunctionsMap[functionName];

    return param == null ? await fun() : await fun(param);
  }
}
