import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

typedef CustomWillAcceptOnNode = bool Function(
  DragTargetDetails<Node> details,
  Node currentNode,
  Node? parent,
  DragHandlerPosition handlerPosition,
);

typedef CustomAcceptOnNode = void Function(
  DragTargetDetails<Node> details,
  Node currentNode,
  Node? parent,
  DragHandlerPosition handlerPosition,
);

/// Represents all operations of the most common
/// used drag operatons/gestures by the users
@immutable
class NodeDragGestures {
  final void Function(DragArgs, Node node)? onDragStart;

  /// By default this just update [DragNodeController] updating
  /// the current dragged object, and the offset where it is
  /// using [details.globalPosition]
  final void Function(DragUpdateDetails details, Node node)? onDragMove;

  /// If the drag ends, then this will be called
  ///
  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(DraggableDetails)? onDragEnd;

  /// If the drag is cancelled while is into a valid draggable node,
  /// then this will be called
  ///
  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(DraggableDetails)? onDragCanceled;

  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(Velocity velocity, Offset offset)? onDragCompleted;
  // These gestures will be used on both sides
  // on insert above and into the node.
  ///
  /// the unique way to know is the operation will be handled
  /// on between nodes section is if [handlerPosition] is handlerPosition.betweenNodes
  final CustomWillAcceptOnNode onWillAcceptWithDetails;

  final CustomAcceptOnNode onAcceptWithDetails;

  const NodeDragGestures({
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    this.onDragStart,
    this.onDragMove,
    this.onDragEnd,
    this.onDragCanceled,
    this.onDragCompleted,
  });
}
