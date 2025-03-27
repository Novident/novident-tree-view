import 'dart:io';
import 'package:example/common/default_nodes_demo.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/widgets/views/android_view.dart';
import 'package:flutter/material.dart';
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
  final Root _controller = Root(children: defaultNodes);

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
  final Root controller;
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
