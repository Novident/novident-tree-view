import 'package:flutter/cupertino.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// A container node capable of holding multiple child nodes in a hierarchical tree
///
/// Represents a branch node that can contain any type of [Node] as children,
/// similar to a directory in a file system that can hold various file types.
/// Manages child nodes lifecycle and provides state tracking for UI interactions.
///
/// Example Use Case:
/// ```dart
/// class FolderNode extends NodeContainer<FileNode> {
///   final ValueNotifier<bool> _expanded = ValueNotifier(false);
///
///   FolderNode(super.children);
///
///   @override
///   bool get isExpanded => _expanded.value;
///
///   set isExpanded(bool expand) => _expanded.value = expand;
/// }
/// ```
abstract class NodeContainer<T extends Node> extends Node {
  final List<T> children;

  NodeContainer({required this.children});

  /// Whether this container is currently expanded in the UI
  bool get isExpanded;

  /// Indicates if the container has no child nodes
  bool get isEmpty => children.isEmpty;

  /// Indicates if the container has at least one child node
  bool get isNotEmpty => children.isNotEmpty;

  @override
  @mustCallSuper
  void dispose() {
    // Safety check for ChangeNotifier disposal
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    
    // Critical: Always call super dispose first
    super.dispose();
    
    // Cleanup child resources recursively
    for(final child in children) {
      child.dispose();
    }
  }
}
