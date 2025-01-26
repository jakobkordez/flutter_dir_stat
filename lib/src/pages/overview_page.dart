import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/fs_walker_entity.dart';
import 'package:flutter_dir_stat/src/spacing.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key, required this.dir, required this.isRoot});

  final FsWalkerDir dir;
  final bool isRoot;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: widget.isRoot == false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (!widget.isRoot) return Navigator.pop(context);

          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Are you sure?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Confirm'),
                ),
              ],
            ),
          );

          if (confirmed == true) Navigator.pop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.dir.path, style: TextStyle(fontSize: 18)),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => Flex(
              direction: constraints.maxHeight > constraints.maxWidth
                  ? Axis.vertical
                  : Axis.horizontal,
              children: [
                Expanded(child: _buildList()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _drawTree(widget.dir.children),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _drawTree(List<FsWalkerEntity> eList, [int maxDepth = 999]) =>
      LayoutBuilder(builder: (_, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        if (maxDepth < 1 || height < 1 || width < 1 || eList.isEmpty) {
          return Container(color: Colors.black);
        }

        final axis = height > width ? Axis.vertical : Axis.horizontal;
        final main = height > width ? height : width;

        int size = eList.fold(0, (p, e) => p + e.size);

        int i = eList.length;
        while (i > 0) {
          // Width/height of the last element
          final w = (main - i + 1) * eList[i - 1].size / size;
          if (w >= 1) break;
          size -= eList[i - 1].size;
          --i;
        }

        if (i == 0) {
          return Container(color: Colors.black);
        }

        return Flex(
          direction: axis,
          spacing: 1,
          children: eList
              .sublist(0, i)
              .map(
                (c) => Expanded(
                  flex: c.size,
                  child: c is FsWalkerDir
                      ? _drawTree(c.children, maxDepth - 1)
                      : Container(
                          color: _fileColors[c.name.split('.').last.hashCode %
                              _fileColors.length],
                        ),
                ),
              )
              .toList(),
        );

        // final cross = height > width ? width : height;
        // const maxRatio = 5;
        // final minRatio = 1 / maxRatio;

        // final mainArr = <FsWalkerEntity>[];
        // int remainingMain = eList.fold(0, (p, e) => p + e.size);
        // for (var e in eList) {
        //   final width = e.size / remainingMain * main;
        //   final ratio = width / cross;
        //   if (eList.length - mainArr.length > 1 &&
        //       (ratio < minRatio || ratio > maxRatio)) break;
        //   mainArr.add(e);
        //   remainingMain -= e.size;
        //   main -= width + 1;
        // }

        // final cross1 = <FsWalkerEntity>[];
        // int cross1Size = 0;
        // int remainingCross = remainingMain;
        // for (var e in eList.sublist(mainArr.length)) {
        //   if (eList.length - mainArr.length - cross1.length > 1 &&
        //       cross1Size > remainingCross) break;
        //   cross1.add(e);
        //   cross1Size += e.size;
        //   remainingCross -= e.size;
        // }

        // if (mainArr.isEmpty && cross1.isEmpty) {
        //   mainArr.addAll(eList);
        //   remainingMain = 0;
        //   remainingCross = 0;
        // }

        // return Flex(
        //   direction: axis,
        //   spacing: 1,
        //   children: [
        //     ...mainArr.map(
        //       (c) => Expanded(
        //         flex: c.size,
        //         child: c is FsWalkerDir
        //             ? _drawTree(c.children, maxDepth - 1)
        //             : Container(
        //                 color: _fileColors[c.name.split('.').last.hashCode %
        //                     _fileColors.length],
        //               ),
        //       ),
        //     ),
        //     if (remainingMain > 0)
        //       Expanded(
        //         flex: remainingMain,
        //         child: Flex(
        //           direction:
        //               axis == Axis.vertical ? Axis.horizontal : Axis.vertical,
        //           spacing: 1,
        //           children: [
        //             if (cross1.isNotEmpty)
        //               Expanded(
        //                 flex: cross1Size,
        //                 child: _drawTree(cross1, maxDepth),
        //               ),
        //             if (remainingCross > 0)
        //               Expanded(
        //                 flex: remainingCross,
        //                 child: _drawTree(
        //                   eList.sublist(mainArr.length + cross1.length),
        //                   maxDepth,
        //                 ),
        //               ),
        //           ],
        //         ),
        //       )
        //   ],
        // );
      });

  Widget _buildList() => ListView.builder(
        itemExtent: 32,
        itemCount: widget.dir.children.length,
        itemBuilder: (context, index) {
          final e = widget.dir.children[index];
          final isDir = e is FsWalkerDir;
          final icon = isDir ? Icons.folder : Icons.insert_drive_file;
          final color = isDir ? Colors.blue.shade600 : Colors.green.shade600;

          return InkWell(
            onTap: isDir
                ? () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OverviewPage(dir: e, isRoot: false),
                    ));
                  }
                : null,
            // onHover: (value) => setState(() => _hovered = value ? e : null),
            onSecondaryTap: () => print('object'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  Expanded(
                    child: Text(
                      e.name,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    e.sizeString,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: e.size / widget.dir.children.first.size,
                      minHeight: 12,
                    ),
                  )
                ].withSpacing(12),
              ),
            ),
          );
        },
      );
}

final _fileColors = [
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
