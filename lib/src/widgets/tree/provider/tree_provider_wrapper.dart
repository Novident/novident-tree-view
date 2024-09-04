import 'package:flutter/material.dart';
import 'drag_provider.dart';
import '../../../controller/drag_node_controller.dart';
import '../../../controller/tree_controller.dart';
import 'tree_notifier_provider.dart';

@immutable
class TreeProvider extends StatefulWidget {
  final TreeController controller;
  final Widget child;
  const TreeProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<TreeProvider> createState() => _TreeProviderStateWidget();
}

class _TreeProviderStateWidget extends State<TreeProvider> {
  final DragNodeController _dragNodeController = DragNodeController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: _dragNodeController,
          builder: (context, child) {
            return DragNotifierProvider(
              controller: _dragNodeController,
              child: TreeNotifierProvider(
                controller: widget.controller,
                child: widget.child,
              ),
            );
          },
        );
      },
    );
  }
}
