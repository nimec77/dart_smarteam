import 'dart:async';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:dart_smarteam/src/isolate/isolate_result.dart';
import 'package:dart_smarteam/src/isolate/isolate_task.dart';
import 'package:dart_smarteam/src/isolate/smarteam_isolate.dart';

typedef ReturnType = Either<Error, dynamic>;

typedef OnResultCallback = void Function(IsolateResult result);

enum WorkerStatus { idle, processing }

class IsolateParams {
  const IsolateParams(this.sendPort);

  final SendPort sendPort;
}

class Worker {
  Worker(this.name);

  final String name;

  static Worker get empty => _NullWorker();

  WorkerStatus status = WorkerStatus.idle;

  late final Isolate _isolate;
  late final SendPort _sendPort;
  late final ReceivePort _receivePort;
  late final Stream _broadcastReceivePort;
  late final StreamSubscription _broadcastPostSubscription;

  Future<void> init({required OnResultCallback onResult}) async {
    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      SmarteamIsolate.isolateEntryPoint,
      IsolateParams(_receivePort.sendPort),
      debugName: name,
      errorsAreFatal: false,
    );

    _broadcastReceivePort = _receivePort.asBroadcastStream();

    _sendPort = await _broadcastReceivePort.first as SendPort;

    _broadcastPostSubscription = _broadcastReceivePort.listen((dynamic res) {
      status = WorkerStatus.idle;

      onResult(res as IsolateResult);
    });
  }

  void execute(IsolateTask task) {
    status = WorkerStatus.processing;

    _sendPort.send(task);
  }

  Future<void> dispose() async {
    await _broadcastPostSubscription.cancel();
    _isolate.kill();
    _receivePort.close();
  }

  @override
  String toString() => 'Worker($name)';
}

class _NullWorker extends Worker {
  _NullWorker() : super(_kName);

  static const _kName = '_null_worker';

  @override
  Future<void> init({required OnResultCallback onResult}) {
    return Future.value();
  }

  @override
  void execute(IsolateTask task) {
  }

  @override
  Future<void> dispose() {
    return Future.value();
  }

  @override
  String toString() => 'NullWorker';
}
