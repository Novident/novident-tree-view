import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:novident_nodes/novident_nodes.dart';

/// A controller class that manages drag-and-drop operations within a tree structure.
///
/// Tracks the state of a dragged node and its position information during drag operations.
class DragListener {
  Node? draggedNode;
  Node? targetNode;
  Offset? globalPosition;
  Offset? localPosition;

  @internal
  Offset? userPosition;

  DragListener({
    this.draggedNode,
    this.globalPosition,
    this.localPosition,
    this.targetNode,
  });

  /// Returns true when a valid drag operation is active:
  bool get isDragging => draggedNode != null && globalPosition != null;
}

/// An InheritedWidget that provides drag state management to descendant widgets.
///
/// ## Usage
/// ```dart
/// DraggableListener(
///   dragListener: DragListener(),
///   child: YourWidgetTree()
/// )
/// ```
///
/// ## Accessing the Listener
///
/// ```dart
/// final listener = DraggableListener.of(context);
/// if (listener.dragListener.isDragging) {
///   // React to drag state
/// }
/// ```
class DraggableListener extends InheritedWidget {
  /// The drag state controller instance
  final DragListener listener;

  const DraggableListener({
    required super.child,
    required this.listener,
    super.key,
  });

  /// Retrieves the nearest [DraggableListener] instance from the widget tree
  ///
  /// - [context]: Build context for tree traversal
  /// - [listen]: When true (default), registers build dependency
  static DraggableListener of(BuildContext context, {bool listen = true}) {
    if (!context.mounted) {
      throw Exception('Cannot access DraggableListener from unmounted context');
    }

    final DraggableListener? widget = listen
        ? context.dependOnInheritedWidgetOfExactType<DraggableListener>()
        : context.getInheritedWidgetOfExactType<DraggableListener>();

    if (widget == null) {
      throw FlutterError(
          'DraggableListener not found. Wrap your tree with DraggableListener.\n'
          'Ensure your TreeView is within a MaterialApp/CupertinoApp that '
          'contains a DraggableListener in its widget ancestry.');
    }

    return widget;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString(minLevel: minLevel);
  }

  @override
  bool updateShouldNotify(covariant DraggableListener oldWidget) => true;
}
