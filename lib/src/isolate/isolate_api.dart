import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:dart_smarteam/src/isolate/worker.dart';
import 'package:dartz/dartz.dart';
import 'package:dart_smarteam/src/isolate/isolate_result.dart';
import 'package:dart_smarteam/src/isolate/isolate_task.dart';


class IsolateAPI {
  bool isRunning = false;

  var _worker = Worker.empty;

  final _taskQueue = Queue<IsolateTask>();

  final _activeTaskcompleters = <Capability, Completer>{};

  Future<void> turnOn() async {
    if (isRunning) {
      return;
    }

    _worker = Worker('smarteam_worker');

    await _worker.init(onResult: _onTaskFinished);

    isRunning = true;
  }

  void _onTaskFinished(IsolateResult result) {
    _activeTaskcompleters.remove(result.capability)!.complete(result.result);

    if (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      _worker.execute(task);
    }
  }

  Future<Either<Error, R>> compute<P, R>(String functionName, {P? param}) async {
    final capability = Capability();
    final completer = Completer<dynamic>();

    final task = IsolateTask(
      functionName: functionName,
      param: param,
      capability: capability,
    );

    _activeTaskcompleters[capability] = completer;

    if (_worker.status == WorkerStatus.processing) {
      _taskQueue.add(task);
    } else {
      _worker.execute(task);
    }

    final dynamic result = await completer.future;

    if (result is Either<Error, R>) {
      return result;
    }

    if (result is RemoteError) {
      return Left(result);
    }

    return Right(result as R);
  }

  Future<void> turnOff() async {
    await _worker.dispose();

    for (final completer in _activeTaskcompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(Left<RemoteError, dynamic>(
          RemoteError('Cancel because of isolate_compute turn off', 'Stack trace not available'),
        ));
      }
    }

    _activeTaskcompleters.clear();

    _worker = Worker.empty;

    _taskQueue.clear();

    isRunning = false;
  }
}
