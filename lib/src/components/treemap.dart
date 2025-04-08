import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/fs_walker_entity.dart';

class TreeMap extends StatelessWidget {
  final FsWalkerDir dir;

  const TreeMap(this.dir, {super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TreeMapPainter(dir),
        size: Size.infinite,
      );
}

class TreeMapPainter extends CustomPainter {
  FsWalkerDir dir;

  TreeMapPainter(this.dir);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final queue = Queue<QueueEntry>();
    queue.add(QueueEntry(rect, dir));

    while (queue.isNotEmpty) {
      final entry = queue.removeFirst();
      Rect rect = entry.rect;
      final entity = entry.entity;
      final depth = entry.depth;

      if (rect.hasNaN) continue;

      final width = rect.width;
      final height = rect.height;
      if (width <= 1 || height <= 1) continue;

      if (depth == 1) {
        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        rect = rect.deflate(2);
      }

      if (entity is FsWalkerFile) {
        final ext = entity.name.split('.').last;
        final paint = Paint()
          ..color = colors[ext.hashCode % colors.length].withAlpha(200);
        canvas.drawRect(rect, paint);
        paint
          ..color = Colors.white.withAlpha(128)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        continue;
      }

      if (entity is! FsWalkerDir) continue;

      int totalSize = entity.children.fold(0, (t, e) => t + e.size);

      int i = 0;
      final children = entity.children;
      while (i < children.length && rect.width > 1 && rect.height > 1) {
        final width = rect.width;
        final height = rect.height;

        if (height * width * children[i].size / totalSize < 4) {
          canvas.drawRect(rect, Paint()..color = Colors.grey.shade400);
          break;
        }

        final main = width > height ? width : height;
        final cross = width > height ? height : width;

        final left = <FsWalkerEntity>[children[i]];
        int leftSize = children[i].size;
        int rightSize = totalSize - leftSize;
        i++;

        double best = double.infinity;
        while (i < children.length) {
          final child = children[i];

          // Check aspect if placed in same col/row
          final h = cross * child.size / (child.size + leftSize);
          final w = main * (child.size + leftSize) / totalSize;
          final aspect = h > w ? h / w : w / h;

          // If worse, make new row/col
          if (aspect > best) break;
          best = aspect;

          // Else add to current row/col
          rightSize -= child.size;
          leftSize += child.size;
          left.add(child);
          i++;
        }

        final Rect leftRect;
        final Rect rightRect;
        if (width > height) {
          leftRect = Rect.fromLTWH(
            rect.left,
            rect.top,
            rect.width * leftSize / totalSize,
            rect.height,
          );
          rightRect = Rect.fromLTRB(
            leftRect.right, //rect.left + leftRect.width,
            rect.top,
            rect.right,
            rect.bottom,
          );
        } else {
          leftRect = Rect.fromLTWH(
            rect.left,
            rect.top,
            rect.width,
            rect.height * leftSize / totalSize,
          );
          rightRect = Rect.fromLTRB(
            rect.left,
            leftRect.bottom, //rect.top + leftRect.height,
            rect.right,
            rect.bottom,
          );
        }

        {
          Rect rect = leftRect;
          final width = rect.width;
          final height = rect.height;

          for (final child in left) {
            Rect curr;
            if (width > height) {
              curr = Rect.fromLTWH(
                rect.left,
                rect.top,
                width * child.size / leftSize,
                height,
              );
              rect = Rect.fromLTRB(
                curr.right, //rect.left + curr.width,
                rect.top,
                rect.right,
                rect.bottom,
              );
            } else {
              curr = Rect.fromLTWH(
                rect.left,
                rect.top,
                width,
                height * child.size / leftSize,
              );
              rect = Rect.fromLTRB(
                rect.left,
                curr.bottom, //rect.top + curr.height,
                rect.right,
                rect.bottom,
              );
            }
            queue.add(QueueEntry(curr, child, depth + 1));
          }
        }

        rect = rightRect;
        totalSize = rightSize;
      }
    }
  }
}

class QueueEntry {
  final Rect rect;
  final FsWalkerEntity entity;
  final int depth;

  QueueEntry(this.rect, this.entity, [this.depth = 0]);
}

final colors = [
  Colors.blue.shade400,
  Colors.green.shade400,
  Colors.red.shade400,
  Colors.orange.shade400,
  Colors.purple.shade400,
  Colors.pink.shade400,
  Colors.teal.shade400,
  Colors.indigo.shade400,
  Colors.deepOrange.shade400,
];
