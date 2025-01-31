abstract class FsWalkerEntity {
  String get path;
  String get name;
  int get size;

  String get sizeString {
    const units = [" B", "kB", "MB", "GB"];
    int size = this.size;
    int unitIndex = 0;
    while (unitIndex < units.length - 1 && size >= 1024) {
      size ~/= 1024;
      unitIndex++;
    }
    return "$size ${units[unitIndex]}";
  }
}

class FsWalkerDir extends FsWalkerEntity {
  @override
  final String path;
  @override
  late final String name =
      '${path.substring(0, path.length - 1).split('/').last}/';

  final List<FsWalkerDir> dirs;
  final List<FsWalkerFile> files;

  late final List<FsWalkerEntity> children = [...dirs, ...files]
    ..sort((a, b) => b.size - a.size);

  FsWalkerDir({required this.path, required this.dirs, required this.files});

  @override
  late final int size = children.fold(0, (acc, c) => acc + c.size);

  @override
  String toString({int maxDepth = 255, int minSize = 0}) {
    return _toString(0, maxDepth, minSize);
  }

  String _toString(int depth, int maxDepth, int minSize) {
    final indent = " " * depth;
    String result =
        '${sizeString.padLeft(7)}  $indent${path.substring(depth)}\n';
    if (maxDepth > 0) {
      result += dirs
          .where((dir) => dir.size >= minSize)
          .map((dir) => dir._toString(path.length, maxDepth - 1, minSize))
          .join();
      result += files
          .where((file) => file.size >= minSize)
          .map((file) => file._toString(path.length))
          .join();
    }
    return result;
  }
}

class FsWalkerFile extends FsWalkerEntity {
  @override
  final String path;
  @override
  late final String name = path.split('/').last;
  @override
  final int size;

  FsWalkerFile({required this.path, required this.size});

  String _toString(int depth) {
    String indent = " " * depth;
    return '${sizeString.padLeft(7)}  $indent$name\n';
  }
}
