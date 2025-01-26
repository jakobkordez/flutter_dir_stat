import 'package:flutter/material.dart';
import 'package:flutter_dir_stat/src/pages/home_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterDirStat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade200,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
