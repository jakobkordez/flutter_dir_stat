import 'dart:io';

import 'package:flutter_dir_stat/src/fs_walker.dart';

Future<void> main(List<String> args) async {
  final dir = Directory(args.first);

  var start = DateTime.now();
  final walkResult = await FsWalker(dir).result;
  print(walkResult.toString(maxDepth: 3, minSize: 1024 * 1024));
  // print(walkResult.size);
  print("${DateTime.now().difference(start).inSeconds}s");
}
