import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/fs_walker_entity.dart';

class Treemap extends LeafRenderObjectWidget {
  final FsWalkerDir dir;

  const Treemap(this.dir, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TreemapRenderBox(dir);
  }

  @override
  void updateRenderObject(BuildContext context, TreemapRenderBox renderObject) {
    renderObject.dir = dir;
  }
}

class TreemapRenderBox extends RenderBox {
  FsWalkerDir dir;

  TreemapRenderBox(this.dir);

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final queue = Queue<QueueEntry>();
    queue.add(QueueEntry(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      dir,
    ));

    while (queue.isNotEmpty) {
      final entry = queue.removeFirst();
      final rect = entry.rect;
      final entity = entry.entity;

      final width = rect.width;
      final height = rect.height;

      if (entity is FsWalkerFile) {
        final ext = entity.name.split('.').last;
        final paint = Paint()..color = colors[ext.hashCode % colors.length];
        context.canvas.drawRect(rect, paint);
        continue;
      }

      if (width < 1 || height < 1) {
        final paint = Paint()..color = Colors.black;
        context.canvas.drawRect(rect, paint);
        continue;
      }

      double main = width > height ? width : height;

      var children = (entity as FsWalkerDir).children;

      int i = children.length;
      while (i > 0 && (main - i + 1) * children[i - 1].size / entity.size < 1) {
        --i;
      }

      if (i == 0) {
        final paint = Paint()..color = Colors.black;
        context.canvas.drawRect(rect, paint);
        continue;
      }

      children = children.sublist(0, i);
      int total = children.fold(0, (p, e) => p + e.size);

      Offset o = Offset(rect.left, rect.top);
      for (final child in children) {
        --i;
        final w = (main - i) * child.size / total;
        main -= w + 1;
        total -= child.size;
        if (width > height) {
          queue.add(QueueEntry(Rect.fromLTWH(o.dx, o.dy, w, height), child));
          o = Offset(o.dx + w + 1, o.dy);
        } else {
          queue.add(QueueEntry(Rect.fromLTWH(o.dx, o.dy, width, w), child));
          o = Offset(o.dx, o.dy + w + 1);
        }
      }
    }
  }
}

class QueueEntry {
  final Rect rect;
  final FsWalkerEntity entity;

  QueueEntry(this.rect, this.entity);
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
