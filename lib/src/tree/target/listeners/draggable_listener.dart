import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

/// A controller class that manages drag-and-drop operations within a tree structure.
///
/// Tracks the state of a dragged node and its position information during drag operations.
///
/// ## Properties
/// - [draggedNode]: The currently dragged tree node (null when not dragging)
/// - [globalPosition]: The drag position in global coordinates (screen-relative)
/// - [localPosition]: The drag position in local coordinates (widget-relative)
///
/// ## State Check
/// - [isDragging]: Returns true when a valid drag operation is in progress
///
/// ## Usage
/// ```dart
/// final dragListener = DragListener(
///   draggedNode: currentlyDraggedNode,
///   globalPosition: Offset(100, 200),
///   localPosition: Offset(50, 75)
/// );
///
/// if (dragListener.isDragging) {
///   // Handle active drag
/// }
/// ```
class DragListener {
  Node? draggedNode;
  Node? targetNode;
  Offset? globalPosition;
  Offset? localPosition;

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
  final DragListener dragListener;

  DraggableListener({
    required super.child,
    DragListener? dragListener,
    super.key,
  }) : dragListener = dragListener ?? DragListener();

  /// Retrieves the nearest [DraggableListener] instance from the widget tree
  ///
  /// - [context]: Build context for tree traversal
  /// - [listen]: When true (default), registers build dependency
  static DraggableListener of(BuildContext context, {bool listen = true}) {
    if (!context.mounted) {
      throw Exception('Cannot access DraggableListener from unmounted context');
    }

    final DraggableListener? listener = listen
        ? context.dependOnInheritedWidgetOfExactType<DraggableListener>()
        : context.getInheritedWidgetOfExactType<DraggableListener>();

    if (listener == null) {
      throw FlutterError(
          'DraggableListener not found. Wrap your tree with DraggableListener.\n'
          'Ensure your TreeView is within a MaterialApp/CupertinoApp that '
          'contains a DraggableListener in its widget ancestry.');
    }

    return listener;
  }

  @override
  bool updateShouldNotify(covariant DraggableListener oldWidget) => false;
}
