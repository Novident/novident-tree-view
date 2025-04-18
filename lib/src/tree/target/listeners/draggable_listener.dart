import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

class DragListener {
  Node? draggedNode;
  Offset? globalPosition;
  Offset? localPosition;

  DragListener({
    this.draggedNode,
    this.globalPosition,
    this.localPosition,
  });

  bool get isDragging => draggedNode != null && globalPosition != null;
}

class DraggableListener extends InheritedWidget {
  final DragListener dragListener;
  DraggableListener({
    required super.child,
    DragListener? dragListener,
    super.key,
  }) : dragListener = dragListener ?? DragListener();

  static DraggableListener of(BuildContext context, {bool listen = true}) {
    if (!context.mounted) {
      throw Exception(
        'An unmounted widget '
        'is not valid to use for '
        'get instance of DraggableListener.',
      );
    }
    final DraggableListener? listener = !listen
        ? context.getInheritedWidgetOfExactType<DraggableListener>()
        : context.dependOnInheritedWidgetOfExactType<DraggableListener>();
    if (listener == null) {
      throw FlutterErrorDetails(
        exception: Exception('MissingDraggableListener'),
        library: 'novident_tree_view',
        context: ErrorDescription(
          'DraggableListener was not founded into the widget '
          'tree. Please, ensure that you wrap your '
          'MaterialApp/Widget where TreeView is used with '
          'DraggableListener '
          'to avoid seeing these type of errors.',
        ),
        silent: true,
      );
    }
    return listener;
  }

  @override
  bool updateShouldNotify(covariant DraggableListener oldWidget) => false;
}
