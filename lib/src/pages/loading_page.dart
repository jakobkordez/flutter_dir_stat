import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/fs_walker.dart';
import 'package:flutter_dir_stat/src/pages/overview_page.dart';
import 'package:flutter_dir_stat/src/spacing.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key, required this.path});

  final String path;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final FsWalker _fsWalker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fsWalker = FsWalker(Directory(widget.path));
    _fsWalker.result.then((value) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OverviewPage(dir: value, isRoot: true),
        ),
      );
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _fsWalker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('FlutterDirStat'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              if (_isLoading) Text('Traversing...') else Text('Done'),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ].withSpacing(16),
          ),
        ),
      );
}
