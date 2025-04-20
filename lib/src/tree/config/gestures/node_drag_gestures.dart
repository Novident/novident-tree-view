import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// A callback that determines whether a dragged node can be accepted by a target node.
///
/// [details] contains information about the dragged node and its original position.
/// [dragDetails] provides information about the current drag operation.
/// [parent] is the potential parent container where the node might be dropped.
/// Returns `true` if the target node can accept the dragged node, `false` otherwise.
typedef NovOnWillAcceptOnNode = bool Function(
  NovDragAndDropDetails<Node>? details,
  DragTargetDetails<Node> dragDetails,
  NodeContainer? parent,
);

/// A callback that handles the acceptance of a dragged node by a target node.
///
/// [details] contains information about the dragged node and its original position.
/// [parent] is the container where the node has been dropped.
typedef NovOnAcceptOnNode = void Function(
  NovDragAndDropDetails<Node> details,
  NodeContainer? parent,
);

/// Defines all the callback handlers for drag-and-drop operations involving [Node] objects.
///
/// This immutable class encapsulates all the possible interactions during a drag-and-drop
/// operation, including start, move, update, completion, cancellation, and acceptance events.
/// Each callback corresponds to a specific phase in the drag-and-drop lifecycle.
///
/// Example usage:
/// ```dart
/// NodeDragGestures(
///   onWillAcceptWithDetails: (details, dragDetails, parent) => true,
///   onAcceptWithDetails: (details, parent) => print('Node accepted'),
///   onDragStart: (offset, node) => print('Drag started'),
/// )
/// ```
@immutable
final class NodeDragGestures {
  /// Called when a drag operation starts.
  ///
  /// [offset] is the position where the drag started.
  /// [node] is the node being dragged.
  final void Function(Offset offset, Node node)? onDragStart;

  /// Called when a dragged node moves over potential drop targets.
  ///
  /// [details] contains information about the current drag position and the node being dragged.
  final void Function(DragTargetDetails<Node> details)? onDragMove;

  /// Called during the drag operation when the pointer moves.
  ///
  /// [details] provides updated information about the drag position and delta.
  final void Function(DragUpdateDetails details)? onDragUpdate;

  /// Called when the drag operation ends (the pointer is released).
  ///
  /// [details] contains information about how the drag ended (whether it was dropped).
  final void Function(DraggableDetails)? onDragEnd;

  /// Called when the drag operation is canceled while over a valid draggable node.
  ///
  /// [velocity] represents the speed of the pointer when the drag was canceled.
  /// [point] is the position where the drag was canceled.
  final void Function(Velocity velocity, Offset point)? onDragCanceled;

  /// Called when a dragged node leaves a potential drop target without being dropped.
  ///
  /// [data] is the node that left the target area.
  final void Function(Node data)? onLeave;

  /// Called when a drag operation completes successfully (the node was dropped and accepted).
  ///
  /// [node] is the node that was successfully dragged and dropped.
  final void Function(Node node)? onDragCompleted;

  /// Determines whether a dragged node can be accepted by a potential drop target.
  ///
  /// See [NovOnWillAcceptOnNode] for details.
  final NovOnWillAcceptOnNode onWillAcceptWithDetails;

  /// Handles the acceptance of a dragged node by a drop target.
  ///
  /// See [NovOnAcceptOnNode] for details.
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
