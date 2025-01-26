import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_dir_stat/src/fs_walker_entity.dart';

class FsWalker {
  late final Isolate _isolate;
  late final ReceivePort _receivePort;
  SendPort? _sendPort;

  final Completer<FsWalkerDir> _completer = Completer();
  Future<FsWalkerDir> get result => _completer.future;

  /// Spawns an isolate to walk the directory.
  FsWalker(Directory dir) {
    _receivePort = ReceivePort();
    Isolate.spawn(_walk, _IsolateParams(_receivePort.sendPort, dir))
        .then((isolate) {
      print('Spawned isolate');
      return _isolate = isolate;
    });

    _receivePort.listen((message) {
      if (message is FsWalkerDir) {
        print('Got result');
        _completer.complete(message);
        _receivePort.close();
        _isolate.kill();
      } else if (message is SendPort) {
        print('Got send port');
        _sendPort = message;
      }
    });
  }

  void cancel() {
    if (!_completer.isCompleted) {
      print('Cancelling isolate');
      _completer.completeError(Exception('Cancelled'));
    }
    _sendPort?.send(null);
    _receivePort.close();
    _isolate.kill();
  }

  static Future<void> _walk(_IsolateParams params) async {
    final receivePort = ReceivePort();
    params.sendPort.send(receivePort.sendPort);

    final res = await _walkDir(params.dir, receivePort.asBroadcastStream());

    params.sendPort.send(res);
  }

  static Future<FsWalkerDir> _walkDir(
      Directory dir, Stream<void> receivePort) async {
    // print(dir.path);
    final dirs = <FsWalkerDir>[];
    final files = <FsWalkerFile>[];

    bool cancelled = false;
    receivePort.listen((message) {
      print('Got cancelled');
      cancelled = true;
    });

    final stream = dir.list(followLinks: false).handleError((e) {});
    await for (final entity in stream) {
      if (cancelled) {
        print('Breaking for cancelled');
        break;
      }
      if (entity is Directory) {
        dirs.add(await _walkDir(entity, receivePort));
      } else if (entity is File) {
        final path = entity.path.replaceAll("\\", "/");
        files.add(await entity
            .length()
            .catchError((e) => 0)
            .then((size) => FsWalkerFile(path: path, size: size)));
      }
    }

    String p = dir.path.replaceAll("\\", "/");
    if (!p.endsWith("/")) p = "$p/";

    return FsWalkerDir(
      path: p,
      dirs: dirs..sort((a, b) => b.size - a.size),
      files: files..sort((a, b) => b.size - a.size),
    );
  }
}

class _IsolateParams {
  final SendPort sendPort;
  final Directory dir;

  _IsolateParams(this.sendPort, this.dir);
}

extension CompleterX<T> on Completer<T> {
  void tryComplete(T value) {
    if (!isCompleted) {
      complete(value);
    }
  }
}
