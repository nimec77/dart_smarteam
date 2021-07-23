import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:smarteam/src/isolate/isolate_result.dart';
import 'package:smarteam/src/isolate/isolate_task.dart';

import 'worker.dart';

class IsolateAPI {
  var isRunning = false;

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
    final completer = Completer();

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

    final result = await completer.future;

    if (result is Either<Error, R>) {
      return result;
    }

    if (result is RemoteError) {
      return Left(result);
    }

    return Right(result);
  }

  Future<void> turnOff() async {
    await _worker.dispose();

    for (final completer in _activeTaskcompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(Left(
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
