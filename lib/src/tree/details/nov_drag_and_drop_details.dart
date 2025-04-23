import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// The details of the drag-and-drop relationship of [NodeTargetBuilder] and
/// [NodeDraggableBuilder].
///
/// Details are created and updated when a node [draggedNode] starts being dragged or when it is hovering
/// another node [targetNode].
///
/// Contains the exact position where the drop ocurred [globalDropPosition] as well
/// as the bounding box [targetBounds] with [globalTargetNodeOffset] of the target widget 
/// which enables many different ways for a node to adopt another node depending 
/// on where it was dropped.
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
    this.rejectedData = const <dynamic>[],
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

  /// The exact global hovering position of [draggedNode] inside [targetBounds].
  final Offset globalDropPosition;

  /// The exact global position of the targetBounds on the screen.
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

  DragHandlerPosition exactPosition() {
    return mapDropPosition(
            whenAbove: () => DragHandlerPosition.above,
            whenInside: () => DragHandlerPosition.into,
            whenBelow: () => DragHandlerPosition.below) ??
        DragHandlerPosition.unknown;
  }

  /// Determines the relative vertical position of a dragged node relative to a target widget
  /// and returns a value based on the current drop position.
  ///
  /// This method provides a flexible way to handle different drop zones by:
  ///
  /// 1. Calculating vertical position boundaries with customizable thresholds
  /// 2. Evaluating the current drag position against these boundaries
  /// 3. Executing the appropriate callback based on the position zone
  ///
  /// ## Parameters
  ///
  /// - [whenAbove]: Callback executed when node is in the upper threshold zone
  /// - [whenInside]: Callback executed when node is in the main content zone
  /// - [whenBelow]: Callback executed when node is in the lower threshold zone
  /// - [aboveZoneHeight]: Size of the upper threshold zone (default: 7 logical pixels)
  /// - [belowZoneHeight]: Size of the lower threshold zone (default: 5.5 logical pixels)
  ///
  /// ## Visual Representation
  /// ```
  /// ┌───────────────────────────────┐
  /// │          Above Zone           │ (above zone height)
  /// ├───────────────────────────────┤
  /// │                               │
  /// │                               │
  /// │         Inside Zone           │ (main content area)
  /// │                               │
  /// │                               │
  /// ├───────────────────────────────┤
  /// │          Below Zone           │ (below zone height)
  /// └───────────────────────────────┘
  /// ```
  ///
  /// ## Usage Example
  /// ```dart
  /// final dropAction = details.mapDropPosition(
  ///   whenAbove: () => 'InsertBefore',
  ///   whenInside: () => 'AddAsChild',
  ///   whenBelow: () => 'InsertAfter',
  ///   aboveZoneHeight: 10,
  ///   belowZoneHeight: 10,
  /// );
  /// ```
  P? mapDropPosition<P>({
    required P Function() whenAbove,
    required P Function() whenInside,
    required P Function() whenBelow,
    bool ignoreInsideZone = false,
    bool ignoreAboveZone = false,
    bool ignoreBelowZone = false,
    double aboveZoneHeight = 7,
    double belowZoneHeight = 5.5,
  }) {
    final double cursorPos = globalDropPosition.dy;
    if (cursorPos < globalTargetNodeOffset.dy ||
        cursorPos > (globalTargetNodeOffset.dy + targetBounds.height)) {
      return null;
    }
    assert(aboveZoneHeight >= 0, 'Above zone cannot be negative');
    assert(belowZoneHeight >= 0, 'Below zone cannot be negative');
    final double effectiveAboveZone =
        globalTargetNodeOffset.dy + aboveZoneHeight;
    final double effectiveBelowZone =
        (globalTargetNodeOffset.dy + targetBounds.height) - belowZoneHeight;
    final bool isInAboveZone = cursorPos <= effectiveAboveZone;
    final bool isInBelowZone = cursorPos >= effectiveBelowZone;
    final bool isInsideZone =
        ignoreBelowZone && ignoreAboveZone && !ignoreInsideZone
            ? true
            : !isInAboveZone && !isInBelowZone;

    if (isInAboveZone && !ignoreAboveZone) {
      return whenAbove();
    }
    if (isInsideZone && !ignoreInsideZone) {
      return whenInside();
    }
    if (isInBelowZone && !ignoreBelowZone) {
      return whenBelow();
    }

    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('draggedNode', draggedNode))
      ..add(DiagnosticsProperty<T>('targetNode', targetNode))
      ..add(DiagnosticsProperty<Offset>('dropPosition', dropPosition))
      ..add(DiagnosticsProperty<Offset>(
          'globalTargetNodeOffset', globalTargetNodeOffset))
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
