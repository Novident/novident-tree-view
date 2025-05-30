import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

const int kLongPressTimeout = 500;

typedef EffectiveDragAnchorStrategy = Offset Function(
  Draggable<Object> draggable,
  BuildContext context,
  Offset? catchedUserCursorOffset,
  Offset position,
);

@immutable
final class DraggableConfigurations {
  /// Constructs the visual feedback widget displayed during a drag operation.
  ///
  /// This builder is used by [Draggable] and [LongPressDraggable] widgets to
  /// create a visual representation of the dragged node. The feedback widget
  /// is typically shown under the user's finger or cursor while dragging.
  final Widget Function(Node node, BuildContext context)
      buildDragFeedbackWidget;

  /// Display the feedback anchored at the position of the original child.
  ///
  /// If feedback is identical to the child, then this means the feedback will
  /// exactly overlap the original child when the drag starts.
  final EffectiveDragAnchorStrategy childDragAnchorStrategy;
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

  const DraggableConfigurations({
    required this.buildDragFeedbackWidget,
    this.allowAutoExpandOnHover = true,
    this.preferLongPressDraggable = false,
    this.childDragAnchorStrategy = _effectiveChildAnchorStrategy,
    this.feedbackOffset = Offset.zero,
    int? longPressDelay,
    this.axis,
    this.childWhenDraggingBuilder,
  }) : longPressDelay = longPressDelay ??
            (preferLongPressDraggable ? kLongPressTimeout : 0);

  DraggableConfigurations copyWith({
    Widget Function(Node, BuildContext)? buildDragFeedbackWidget,
    EffectiveDragAnchorStrategy? childDragAnchorStrategy,
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
Offset _effectiveChildAnchorStrategy(
  Draggable<Object> draggable,
  BuildContext context,
  Offset? catchedUserCursorOffset,
  Offset position,
) {
  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
  catchedUserCursorOffset ??= Offset.zero;
  // gets the real local offset that is effective to appear where the user
  // is making the interaction
  final Offset effectiveOffset = renderObject.globalToLocal(position) -
      // put manually the offset to be the near as we can
      (catchedUserCursorOffset - _effectiveDecreaserOffset);
  return effectiveOffset;
}

const Offset _effectiveDecreaserOffset = Offset(10, 15);
