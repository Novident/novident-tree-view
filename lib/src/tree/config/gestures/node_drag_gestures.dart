import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/extensions/cast_nodes.dart';

/// A callback that determines whether a dragged node can be accepted by a target node.
typedef NovOnWillAcceptOnNode = bool Function(
  NovDragAndDropDetails<Node>? details,
  DragTargetDetails<Node> dragDetails,
  Node target,
  NodeContainer? parent,
);

/// A callback that handles the acceptance of a dragged node by a target node.
typedef NovOnAcceptOnNode = void Function(
  NovDragAndDropDetails<Node> details,
  Node target,
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
///   onWillAcceptWithDetails: (details, dragDetails, target, parent) => true,
///   onAcceptWithDetails: (details, target, parent) => print('Node accepted'),
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

  /// Creates a standard and basic Drag and Drop gestures
  ///
  /// You can use [onWillInsert] property, to listen the new states of the nodes
  /// that will be inserted into the new owner
  factory NodeDragGestures.standardDragAndDrop({
    NovOnWillAcceptOnNode? onWillAcceptWithDetails,
    void Function(Node node, NodeContainer newOwner, int level)? onWillInsert,
    void Function(DragTargetDetails<Node> details)? onDragMove,
    void Function(Offset offset, Node node)? onDragStart,
    void Function(DragUpdateDetails details)? onDragUpdate,
    void Function(Node data)? onLeave,
    void Function(DraggableDetails)? onDragEnd,
    void Function(Velocity velocity, Offset point)? onDragCanceled,
    void Function(Node node)? onDragCompleted,
  }) {
    return NodeDragGestures(
      onWillAcceptWithDetails: onWillAcceptWithDetails ?? _standardOnWillAccept,
      onAcceptWithDetails: (
        NovDragAndDropDetails<Node> details,
        Node target,
        NodeContainer? parent,
      ) =>
          _standardOnAccept(
        details,
        onWillInsert,
        target,
        parent,
      ),
      onDragMove: onDragMove,
      onDragStart: onDragStart,
      onLeave: onLeave,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      onDragCanceled: onDragCanceled,
      onDragCompleted: onDragCompleted,
    );
  }

  static void _standardOnAccept(
    NovDragAndDropDetails<Node> details,
    void Function(Node node, NodeContainer newOwner, int level)? onWillInsert,
    Node target,
    NodeContainer? parent,
  ) {
    final Node target = details.targetNode;
    details.mapDropPosition<void>(
      whenAbove: () {
        final NodeContainer parent = target.owner as NodeContainer;
        onWillInsert?.call(
          details.draggedNode,
          parent,
          parent.level + 1,
        );
        final int effectiveIndex = target.index;

        if (effectiveIndex == details.draggedNode.index) {
          return;
        }
        Node.moveTo(
          node: details.draggedNode,
          newOwner: parent,
          index: effectiveIndex,
          shouldNotify: true,
          propagate: true,
        );
      },
      whenInside: () {
        if (Node.canMoveTo(
            node: details.draggedNode, target: target, inside: true)) {
          final NodeContainer dragParent =
              details.draggedNode.owner as NodeContainer;
          dragParent
            ..removeWhere(
              (Node n) => n.id == details.draggedNode.id,
              shouldNotify: false,
            )
            ..notify(propagate: true);
          onWillInsert?.call(
            details.draggedNode,
            target as NodeContainer,
            target.level + 1,
          );
          Node.moveTo(
            node: details.draggedNode,
            newOwner: target.castToContainer(),
            index: null,
            shouldNotify: true,
            propagate: true,
          );
        }
      },
      whenBelow: () {
        final NodeContainer parent = target.owner as NodeContainer;
        onWillInsert?.call(
          details.draggedNode,
          parent,
          parent.level,
        );
        // will be inserted at next index
        // the before one effective, is the exact current
        final int targetIndex = target.index;
        final int draggedIndex = details.draggedNode.index;

        // adjust the index if the dragged node is before the target
        int effectiveIndex =
            draggedIndex < targetIndex ? targetIndex : targetIndex + 1;

        if (effectiveIndex == draggedIndex) {
          return;
        }

        Node.moveTo(
          node: details.draggedNode,
          newOwner: parent,
          index: effectiveIndex,
          shouldNotify: true,
          propagate: true,
        );
      },
      ignoreInsideZone: target is! NodeContainer,
    );
    return;
  }

  static bool _standardOnWillAccept(
    NovDragAndDropDetails<Node>? details,
    DragTargetDetails<Node> dragDetails,
    Node target,
    NodeContainer? parent,
  ) {
    return Node.canMoveTo(
      node: details?.draggedNode ?? dragDetails.data,
      target: details?.targetNode ?? target,
      inside: details == null
          ? true
          : details.exactPosition() == DragHandlerPosition.into,
    );
  }
}
