import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/components/treemap.dart';
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
                    child: Treemap(widget.dir),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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
