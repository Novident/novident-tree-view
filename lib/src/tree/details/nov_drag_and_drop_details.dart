import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:novident_nodes/novident_nodes.dart';

/// The details of the drag-and-drop relationship of [TreeDraggable] and
/// [TreeDragTarget].
///
/// Details are created and updated when a node [draggedNode] is hovering
/// another node [targetNode].
///
/// Contains the exact position where the drop ocurred [dropPosition] as well
/// as the bounding box [targetBounds] of the target widget which enables many
/// different ways for a node to adopt another node depending on where it was
/// dropped.
///
/// The following example splits the height of [targetBounds] in three and
/// decides where to drop [draggedNode] depending on the `dy` property of
/// [dropPosition]:
class NovDragAndDropDetails<T extends Node> with Diagnosticable {
  /// Creates a [NovDragAndDropDetails].
  const NovDragAndDropDetails({
    required this.draggedNode,
    required this.targetNode,
    required this.dropPosition,
    required this.targetBounds,
    required this.globalDropPosition,
    required this.globalTargetNodeOffset,
    this.candidateData = const [],
    this.rejectedData = const [],
  });

  /// The node that was dragged around and dropped on [targetNode].
  final T draggedNode;

  /// The node that received the drop of [draggedNode].
  final T targetNode;

  /// The exact hovering position of [draggedNode] inside [targetBounds].
  ///
  /// This can be used to decide what will happen to [draggedNode] once it is
  /// dropped at this vicinity of [targetBounds], whether it will become a
  /// child of [targetNode], a sibling, its parent, etc.
  final Offset dropPosition;

  //
  final Offset globalDropPosition;
  final Offset globalTargetNodeOffset;

  /// The widget bounding box of [targetNode].
  ///
  /// This combined with [dropPosition] can be used to allow the user to drop
  /// the dragging node at different parts of the target node which could lead
  /// to different behaviors, e.g. drop as: previous sibling, first child, last
  /// child, next sibling, parent, etc.
  final Rect targetBounds;

  /// Contains the list of drag data that is hovering over the [TreeDragTarget]
  /// that that will be accepted by the [TreeDragTarget].
  ///
  /// This and [rejectedData] are collected from the data given to the builder
  /// callback of the [DragTarget] widget.
  final List<T?> candidateData;

  /// Contains the list of drag data that is hovering over this [TreeDragTarget]
  /// that will not be accepted by the [TreeDragTarget].
  ///
  /// This and [candidateData] are collected from the data given to the builder
  /// callback of the [DragTarget] widget.
  final List<dynamic> rejectedData;

  @internal
  NovDragAndDropDetails<T> applyData(
    List<T?> candidateData,
    List<dynamic> rejectedData,
  ) {
    return NovDragAndDropDetails<T>(
      draggedNode: draggedNode,
      targetNode: targetNode,
      globalTargetNodeOffset: globalTargetNodeOffset,
      globalDropPosition: globalDropPosition,
      dropPosition: dropPosition,
      targetBounds: targetBounds,
      candidateData: candidateData,
      rejectedData: rejectedData,
    );
  }

  /// Determines the relative position of a dragged node with respect to a target widget
  ///
  /// and returns a corresponding value based on whether the node is:
  ///
  /// - Above the target
  /// - Inside the target
  /// - Below the target
  ///
  /// The method divides the target widget's height into logical sections to determine
  /// the position. The calculations can be customized using the provided parameters.
  ///
  /// - [whenAbove]: Callback that returns the value when the dragged node is above the target
  /// - [whenInside]: Callback that returns the value when the dragged node is inside the target
  /// - [whenBelow]: Callback that returns the value when the dragged node is below the target
  P mapDropPosition<P>({
    required P Function() whenAbove,
    required P Function() whenInside,
    required P Function() whenBelow,
    double upperBoundsLimiter = 5,
    double lowerBoundsLimiter = 5,
  }) {
    final double maxHeight = globalTargetNodeOffset.dy;
    final double pointerVerticalOffset = globalDropPosition.dy;
    final double upperBoundsPart =
        globalTargetNodeOffset.dy + upperBoundsLimiter;
    final double lowerBoundsPart =
        (maxHeight + targetBounds.height) - lowerBoundsLimiter;

    if (pointerVerticalOffset < upperBoundsPart) {
      return whenAbove();
    } else if (pointerVerticalOffset > upperBoundsPart &&
        pointerVerticalOffset < lowerBoundsPart) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('draggedNode', draggedNode))
      ..add(DiagnosticsProperty<T>('targetNode', targetNode))
      ..add(DiagnosticsProperty<Offset>('dropPosition', dropPosition))
      ..add(
          DiagnosticsProperty<Offset>('globalDropPosition', globalDropPosition))
      ..add(DiagnosticsProperty<Rect>('targetBounds', targetBounds));
  }

  NovDragAndDropDetails<T> copyWith({
    T? draggedNode,
    T? targetNode,
    Offset? dropPosition,
    Offset? globalDropPosition,
    Offset? globalTargetNodeOffset,
    Rect? targetBounds,
    List<T?>? candidateData,
    List<dynamic>? rejectedData,
  }) {
    return NovDragAndDropDetails<T>(
      draggedNode: draggedNode ?? this.draggedNode,
      globalDropPosition: globalDropPosition ?? this.globalDropPosition,
      globalTargetNodeOffset:
          globalTargetNodeOffset ?? this.globalTargetNodeOffset,
      targetNode: targetNode ?? this.targetNode,
      dropPosition: dropPosition ?? this.dropPosition,
      targetBounds: targetBounds ?? this.targetBounds,
      candidateData: candidateData ?? this.candidateData,
      rejectedData: rejectedData ?? this.rejectedData,
    );
  }

  @override
  bool operator ==(covariant NovDragAndDropDetails<T> other) {
    if (identical(this, other)) return true;

    return other.draggedNode == draggedNode &&
        other.targetNode == targetNode &&
        other.dropPosition == dropPosition &&
        other.targetBounds == targetBounds &&
        other.globalDropPosition == globalDropPosition &&
        other.globalTargetNodeOffset == globalTargetNodeOffset &&
        listEquals(other.candidateData, candidateData) &&
        listEquals(other.rejectedData, rejectedData);
  }

  @override
  int get hashCode {
    return draggedNode.hashCode ^
        targetNode.hashCode ^
        dropPosition.hashCode ^
        globalTargetNodeOffset.hashCode ^
        globalDropPosition.hashCode ^
        targetBounds.hashCode ^
        candidateData.hashCode ^
        rejectedData.hashCode;
  }
}
