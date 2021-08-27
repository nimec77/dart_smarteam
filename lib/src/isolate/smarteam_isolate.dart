import 'dart:isolate';

import 'package:dart_smarteam/src/isolate/isolate_result.dart';
import 'package:dart_smarteam/src/isolate/isolate_task.dart';
import 'package:dart_smarteam/src/isolate/smarteam_functions/smarteam_function.dart';
import 'package:dart_smarteam/src/isolate/worker.dart';

class SmarteamIsolate {

  static Future<void> isolateEntryPoint(IsolateParams params) async {
    final receivePort = ReceivePort();
    final sendPort = params.sendPort..send(receivePort.sendPort);

    SmarteamFunction.init();

    await for (final task in receivePort.cast<IsolateTask>()) {
      try {
        final dynamic computationResult = await SmarteamFunction.runFunction(task.functionName, param: task.param);

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

  static Future<void> isolateDispose() async {
    await SmarteamFunction.dispose();
  }
}
