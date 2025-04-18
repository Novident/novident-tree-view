import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

const int kLongPressTimeout = 500;

@immutable
class DraggableConfigurations {
  /// Constructs the visual feedback widget displayed during a drag operation.
  ///
  /// This builder is used by [Draggable] and [LongPressDraggable] widgets to
  /// create a visual representation of the dragged node. The feedback widget
  /// is typically shown under the user's finger or cursor while dragging.
  ///
  /// - [node]: The node that is being dragged.
  /// - Returns: A widget that represents the visual feedback during the drag operation.
  final Widget Function(Node node) buildDragFeedbackWidget;

  /// Display the feedback anchored at the position of the original child.
  ///
  /// If feedback is identical to the child, then this means the feedback will
  /// exactly overlap the original child when the drag starts.
  final DragAnchorStrategy childDragAnchorStrategy;
  final Offset feedbackOffset;

  /// The duration that a user has to press down before a long press is registered.
  ///
  /// Defaults to [kLongPressTimeout].
  final int longPressDelay;
  final Axis? axis;

  final bool allowAutoExpandOnHover;

  /// If the current device is Android or IOS the
  /// items will be wrapped by [LongPressDraggable] instead
  /// [Draggable] widget
  final bool preferLongPressDraggable;

  /// Constructs a widget that represents the child node during a drag event.
  ///
  /// This widget is typically used to visually indicate the child node being
  /// dragged. It can customize the appearance of the node while it is being
  /// moved, such as adding a shadow, changing opacity, or applying a preview style.
  final Widget Function(Node node)? childWhenDraggingBuilder;

  DraggableConfigurations({
    required this.buildDragFeedbackWidget,
    this.allowAutoExpandOnHover = true,
    this.preferLongPressDraggable = false,
    this.childDragAnchorStrategy = _childDragAnchorStrategy,
    this.feedbackOffset = Offset.zero,
    this.longPressDelay = kLongPressTimeout,
    this.axis,
    this.childWhenDraggingBuilder,
  });

  DraggableConfigurations copyWith({
    Widget Function(Node node)? buildDragFeedbackWidget,
    DragAnchorStrategy? childDragAnchorStrategy,
    Offset? feedbackOffset,
    int? longPressDelay,
    Axis? axis,
    bool? allowAutoExpandOnHover,
    bool? preferLongPressDraggable,
    Widget Function(Node node)? childWhenDraggingBuilder,
  }) {
    return DraggableConfigurations(
      buildDragFeedbackWidget:
          buildDragFeedbackWidget ?? this.buildDragFeedbackWidget,
      childDragAnchorStrategy:
          childDragAnchorStrategy ?? this.childDragAnchorStrategy,
      feedbackOffset: feedbackOffset ?? this.feedbackOffset,
      longPressDelay: longPressDelay ?? this.longPressDelay,
      axis: axis ?? this.axis,
      allowAutoExpandOnHover:
          allowAutoExpandOnHover ?? this.allowAutoExpandOnHover,
      preferLongPressDraggable:
          preferLongPressDraggable ?? this.preferLongPressDraggable,
      childWhenDraggingBuilder:
          childWhenDraggingBuilder ?? this.childWhenDraggingBuilder,
    );
  }

  @override
  String toString() {
    return 'DraggableConfigurations('
        'buildDragFeedbackWidget: $buildDragFeedbackWidget, '
        'childDragAnchorStrategy: $childDragAnchorStrategy, '
        'feedbackOffset: $feedbackOffset, '
        'longPressDelay: $longPressDelay, '
        'axis: $axis, '
        'allowAutoExpandOnHover: $allowAutoExpandOnHover, '
        'preferLongPressDraggable: $preferLongPressDraggable, '
        'childWhenDraggingBuilder: $childWhenDraggingBuilder'
        ')';
  }

  @override
  bool operator ==(covariant DraggableConfigurations other) {
    if (identical(this, other)) return true;

    return other.buildDragFeedbackWidget == buildDragFeedbackWidget &&
        other.childDragAnchorStrategy == childDragAnchorStrategy &&
        other.feedbackOffset == feedbackOffset &&
        other.longPressDelay == longPressDelay &&
        other.axis == axis &&
        other.allowAutoExpandOnHover == allowAutoExpandOnHover &&
        other.preferLongPressDraggable == preferLongPressDraggable &&
        other.childWhenDraggingBuilder == childWhenDraggingBuilder;
  }

  @override
  int get hashCode {
    return buildDragFeedbackWidget.hashCode ^
        childDragAnchorStrategy.hashCode ^
        feedbackOffset.hashCode ^
        longPressDelay.hashCode ^
        axis.hashCode ^
        allowAutoExpandOnHover.hashCode ^
        preferLongPressDraggable.hashCode ^
        childWhenDraggingBuilder.hashCode;
  }
}

/// Display the feedback anchored at the position of the original child.
///
/// If feedback is identical to the child, then this means the feedback will
/// exactly overlap the original child when the drag starts.
///
/// This is the default [DragAnchorStrategy].
///
/// See also:
///
///  * [DragAnchorStrategy], the typedef that this function implements.
///  * [Draggable.dragAnchorStrategy], for which this is a built-in value.
///
/// Copied from Flutter
Offset _childDragAnchorStrategy(
  Draggable<Object> draggable,
  BuildContext context,
  Offset position,
) {
  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
  return renderObject.globalToLocal(position);
}
