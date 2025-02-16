import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controller/tree_controller.dart';
import 'tree_notifier_provider.dart';

@immutable
class TreeProvider extends StatelessWidget {
  final TreeController controller;
  final Widget child;
  const TreeProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ListenableBuilder(
        listenable: controller,
        child: child,
        builder: (context, child) {
          return TreeNotifierProvider(
            controller: controller,
            child: child!,
          );
        },
      ),
    );
  }
}
