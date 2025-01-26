import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/pages/loading_page.dart';
import 'package:flutter_dir_stat/src/spacing.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterDirStat'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pick a drive or folder to get started',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton(
              onPressed: () {
                FilePicker.platform
                    .getDirectoryPath(dialogTitle: 'Select a folder')
                    .then((value) => setState(() => _selectedPath = value));
              },
              child: Text('Select Folder'),
            ),
            if (_selectedPath != null) ...[
              Text('Selected path: $_selectedPath'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoadingPage(path: _selectedPath!),
                    ),
                  );
                },
                child: Text('Start'),
              ),
            ],
          ].withSpacing(16),
        ),
      ),
    );
  }
}
