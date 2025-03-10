import 'dart:io';
import 'package:example/common/default_nodes_demo.dart';
import 'package:example/widgets/views/android_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'widgets/views/desktop_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TreeController _controller = TreeController(defaultNodes);

  @override
  void initState() {
    _controller.setHandlerToLogger(callback: debugPrint);
    super.initState();
  }

  @override
  void dispose() {
    _controller
      ..dispose()
      ..setHandlerToLogger(callback: null, logLevel: TreeLogLevel.off);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree view Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: MiddlewareView(controller: _controller),
    );
  }
}

class MiddlewareView extends StatelessWidget {
  final TreeController controller;
  const MiddlewareView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      return AndroidTreeViewExample(controller: controller);
    }
    return DesktopTreeViewExample(controller: controller);
  }
}
