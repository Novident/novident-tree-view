import 'package:example/common/entities/root.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

abstract class BaseTreeController extends ChangeNotifier {
  Root get root;

  bool get isEmpty => root.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => root.children.length;

  bool _disposed = false;

  bool get disposed => _disposed;

  @protected
  ValueNotifier<Node?> currentSelectedNode = ValueNotifier(null);

  ValueNotifier<Node?> get selection => currentSelectedNode;

  set children(List<Node> newRoot) {
    root.clearAndOverrideState(newRoot);
    // reload the visual selection since the new root couldn't contain
    // the current node in selection
    selectNode(null);
  }

  Node? get selectedNode => currentSelectedNode.value;

  /// selectNode just makes of the tree directory
  /// select a node
  void selectNode(Node? node) {
    if (currentSelectedNode.value.runtimeType == node.runtimeType) {
      if (currentSelectedNode.value == node) {
        return;
      }
    }
    currentSelectedNode.value = node;
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    root.dispose();
    _disposed = true;
  }
}
