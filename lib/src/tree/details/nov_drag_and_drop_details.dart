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
///
/// ```dart
/// extension on NovDragAndDropDetails<Object> {
///   T mapDropPosition<T>({
///     required T Function() whenAbove,
///     required T Function() whenInside,
///     required T Function() whenBelow,
///   }) {
///     final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
///     final double pointerVerticalOffset = dropPosition.dy;
///
///     if (pointerVerticalOffset < oneThirdOfTotalHeight) {
///        return whenAbove();
///     } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
///       return whenInside();
///     } else {
///       return whenBelow();
///     }
///   }
/// }
/// ```
class NovDragAndDropDetails<T extends Node> with Diagnosticable {
  /// Creates a [NovDragAndDropDetails].
  const NovDragAndDropDetails({
    required this.draggedNode,
    required this.targetNode,
    required this.dropPosition,
    required this.targetBounds,
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
      dropPosition: dropPosition,
      targetBounds: targetBounds,
      candidateData: candidateData,
      rejectedData: rejectedData,
    );
  }

  /// Determines the relative position of a dragged node with respect to a target widget
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
  ///
  /// - [boundsMultiplier]: Determines the size of the upper detection zone.
  ///   Defaults to 0.3 (30% of widget height). This affects how close to the top
  ///   the dragged node needs to be to be considered "above".
  ///
  /// - [insideMultiplier]: Adjusts the size of the middle detection zone.
  ///   Defaults to 2 (making the middle zone 60% of height when combined with default boundsMultiplier).
  ///   Increase/Decreate this value to expand/compress the "inside" detection area.
  ///
  /// - [isAbove]: Optional custom function to override the default "above" detection logic.
  ///   Receives the current drop position and calculated one-third height.
  ///   Return true to force "above" detection.
  ///
  /// - [isInside]: Optional custom function to override the default "inside" detection logic.
  ///   Receives the current drop position and calculated one-third height.
  ///   Return true to force "inside" detection.
  ///
  /// The default behavior divides the widget into three logical sections:
  ///
  /// 1. Top section (above): 0 - 30% of height (when boundsMultiplier is 0.3)
  /// 2. Middle section (inside): 30% - 60% of height
  /// 3. Bottom section (below): remaining 60% - 100% of height
  P mapDropPosition<P>({
    required P Function() whenAbove,
    required P Function() whenInside,
    required P Function() whenBelow,
    double boundsMultiplier = 0.3,
    double insideMultiplier = 2,
    bool Function(double dropPosition, double thirdPartOfWidgetHeight)? isAbove,
    bool Function(double dropPosition, double thirdPartOfWidgetHeight)?
        isInside,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * boundsMultiplier;
    final double pointerVerticalOffset = dropPosition.dy;

    if (isAbove?.call(pointerVerticalOffset, oneThirdOfTotalHeight) ??
        pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (isInside?.call(pointerVerticalOffset, oneThirdOfTotalHeight) ??
        pointerVerticalOffset < (oneThirdOfTotalHeight * insideMultiplier)) {
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
      ..add(DiagnosticsProperty<Rect>('targetBounds', targetBounds));
  }

  NovDragAndDropDetails<T> copyWith({
    T? draggedNode,
    T? targetNode,
    Offset? dropPosition,
    Rect? targetBounds,
    List<T?>? candidateData,
    List<dynamic>? rejectedData,
  }) {
    return NovDragAndDropDetails<T>(
      draggedNode: draggedNode ?? this.draggedNode,
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
        listEquals(other.candidateData, candidateData) &&
        listEquals(other.rejectedData, rejectedData);
  }

  @override
  int get hashCode {
    return draggedNode.hashCode ^
        targetNode.hashCode ^
        dropPosition.hashCode ^
        targetBounds.hashCode ^
        candidateData.hashCode ^
        rejectedData.hashCode;
  }
}
