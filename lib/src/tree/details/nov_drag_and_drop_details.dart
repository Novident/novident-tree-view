import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

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

  P mapDropPosition<P>({
    required P Function() whenAbove,
    required P Function() whenInside,
    required P Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
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
