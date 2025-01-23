import 'dart:io';

class FsWalker {
  static Future<FsWalkerDir> walk(Directory dir) async {
    // print(dir.path);
    final dirs = <Future<FsWalkerDir>>[];
    final files = <Future<FsWalkerFile>>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is Directory) {
          dirs.add(walk(entity));
        } else if (entity is File) {
          files.add(entity
              .length()
              .catchError((e) => 0)
              .then((size) => FsWalkerFile(name: entity.path, size: size)));
        }
      }
    } catch (e) {}

    final d = await Future.wait(dirs);
    d.sort((a, b) => b.size - a.size);
    final f = await Future.wait(files);
    f.sort((a, b) => b.size - a.size);

    String p = dir.path.replaceAll("\\", "/");
    if (!p.endsWith("/")) p = "$p/";

    return FsWalkerDir(
      name: p,
      dirs: d,
      files: f,
    );
  }
}

class FsWalkerDir {
  final String name;
  final List<FsWalkerDir> dirs;
  final List<FsWalkerFile> files;

  FsWalkerDir({required this.name, required this.dirs, required this.files});

  late final int size = dirs.fold(0, (acc, dir) => acc + dir.size) +
      files.fold(0, (acc, file) => acc + file.size);

  @override
  String toString({int maxDepth = 255, int minSize = 0}) {
    return _toString(0, maxDepth, minSize);
  }

  String _toString(int depth, int maxDepth, int minSize) {
    final indent = " " * depth;
    String result =
        '${_getFormattedSize(size).padLeft(7)}  $indent${name.substring(depth)}\n';
    if (maxDepth > 0) {
      result += dirs
          .where((dir) => dir.size >= minSize)
          .map((dir) => dir._toString(name.length, maxDepth - 1, minSize))
          .join();
      result += files
          .where((file) => file.size >= minSize)
          .map((file) => file._toString(name.length))
          .join();
    }
    return result;
  }
}

class FsWalkerFile {
  final String name;
  final int size;

  FsWalkerFile({required this.name, required this.size});

  String _toString(int depth) {
    String indent = " " * depth;
    return '${_getFormattedSize(size).padLeft(7)}  $indent${name.substring(depth)}\n';
  }
}

String _getFormattedSize(int size) {
  const units = [" B", "kB", "MB", "GB"];
  int unitIndex = 0;
  while (size >= 1024) {
    size ~/= 1024;
    unitIndex++;
  }
  return "$size ${units[unitIndex]}";
}
