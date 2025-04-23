import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

/// Contains all the details necessary to know
/// what is the `draggedNode` and the `targetNode`
class NodeDragAndDropDetails {
  final Node draggedNode;
  final Node? targetNode;
  final bool inside;

  NodeDragAndDropDetails({
    required this.draggedNode,
    this.targetNode,
    this.inside = true,
  });
}

/// An InheritedWidget that provides drag and drop details state management to descendant widgets.
class DragAndDropDetailsListener extends InheritedWidget {
  final ValueNotifier<NodeDragAndDropDetails?> details;

  DragAndDropDetailsListener({
    required super.child,
    super.key,
  }) : details = ValueNotifier<NodeDragAndDropDetails?>(null);

  /// Retrieves the nearest [NodeDragAndDropDetails] instance from the widget tree
  ///
  /// - [context]: Build context for tree traversal
  /// - [listen]: When true (default), registers build dependency
  static DragAndDropDetailsListener of(BuildContext context,
      {bool listen = true}) {
    if (!context.mounted) {
      throw Exception(
          'Cannot access DragAndDropDetailsListener from unmounted context');
    }

    final DragAndDropDetailsListener? listener = listen
        ? context
            .dependOnInheritedWidgetOfExactType<DragAndDropDetailsListener>()
        : context.getInheritedWidgetOfExactType<DragAndDropDetailsListener>();

    if (listener == null) {
      throw FlutterError(
          'DragAndDropDetailsListener not found. Wrap your tree with DragAndDropDetailsListener.\n'
          'Ensure your TreeView is within a MaterialApp/CupertinoApp that '
          'contains a DragAndDropDetailsListener in its widget ancestry.');
    }

    return listener;
  }

  @override
  bool updateShouldNotify(covariant DragAndDropDetailsListener oldWidget) =>
      false;
}
