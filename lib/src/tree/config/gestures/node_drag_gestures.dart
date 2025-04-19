import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

typedef NovOnWillAcceptOnNode = bool Function(
  NovDragAndDropDetails<Node>? details,
  DragTargetDetails<Node> dragDetails,
  Node target,
  NodeContainer? parent,
);

typedef NovOnAcceptOnNode = void Function(
  NovDragAndDropDetails<Node> details,
  Node target,
  NodeContainer? parent,
);

/// Represents all operations of the most common
/// used drag operatons/gestures by the users
@immutable
class NodeDragGestures {
  final void Function(Offset offset, Node node)? onDragStart;

  final void Function(DragTargetDetails<Node> details)? onDragMove;

  /// By default this just update [DragNodeController] updating
  /// the current dragged object, and the offset where it is
  /// using [details.globalPosition]
  final void Function(DragUpdateDetails details)? onDragUpdate;

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
  final void Function(Velocity velocity, Offset point)? onDragCanceled;

  /// If the target node was leaved by the dragged node
  final void Function(Node data)? onLeave;

  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(Node node)? onDragCompleted;

  // These gestures will be used on both sides
  // on insert above and into the node.
  ///
  /// the unique way to know is the operation will be handled
  /// on between nodes section is if [handlerPosition] is handlerPosition.betweenNodes
  final NovOnWillAcceptOnNode onWillAcceptWithDetails;

  final NovOnAcceptOnNode onAcceptWithDetails;

  const NodeDragGestures({
    required this.onWillAcceptWithDetails,
    required this.onAcceptWithDetails,
    this.onDragMove,
    this.onDragStart,
    this.onDragUpdate,
    this.onLeave,
    this.onDragEnd,
    this.onDragCanceled,
    this.onDragCompleted,
  });
}
