import 'package:flutter/cupertino.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// [NodeContainer] represents a node that can contains all
/// types of Nodes as its children
///
/// You can take this implementation as a directory from your
/// local storage that can contains a wide variety of file types
abstract class NodeContainer<T extends Node> extends Node {
  final List<T> children;

  NodeContainer({required this.children});

  bool get isExpanded;
  bool get isEmpty;
  bool get isNotEmpty;

  @override
  @mustCallSuper
  void dispose() {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    super.dispose();
    for(final child in children) {
      child.dispose();
    }
  }
}
