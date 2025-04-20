import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/extensions/cast_nodes.dart';
import 'package:novident_tree_view/src/tree/wrapper/default_nodes_wrapper.dart';

/// A widget that wraps either [Draggable] or [LongPressDraggable] depending on
/// the value of [longPressDelay], with additional tree view capabilities.
///
/// It is also responsible for automatically collapsing the node it holds
/// when the drag starts and expanding it back when the drag ends (if it was
/// collapsed). This can be toggled off in [collapseOnDragStart].
///
/// Usage:
/// ```dart
/// Widget build(BuildContext context) {
///   return NodeDraggableBuilder<Node>(
///     node: entry.node,
///     configuration: your configs,
///     child: MyTreeNodeTile(),
///   );
/// }
/// ```
class NodeDraggableBuilder extends StatefulWidget {
  /// Creates a [NodeDraggableBuilder].
  ///
  /// By default, this widget creates a [Draggable] widget, to change it to a
  /// [LongPressDraggable], provide a [longPressDelay] different than `null`.
  const NodeDraggableBuilder({
    required this.child,
    required this.builder,
    required this.configuration,
    required this.node,
    required this.depth,
    super.key,
  });

  /// The widget below this widget in the tree.
  ///
  /// This widget displays [child] when not dragging. If [childWhenDragging] is
  /// non-null, this widget instead displays [childWhenDragging] when dragging.
  /// Otherwise, this widget always displays [child].
  ///
  /// The [feedback] widget is shown under the pointer when dragging.
  final Widget child;

  final TreeConfiguration configuration;

  final NodeComponentBuilder builder;

  final int depth;

  /// The tree node that is going to be provided to [Draggable.data].
  final Node node;

  @override
  State<NodeDraggableBuilder> createState() => _TreeDraggableState();
}

class _TreeDraggableState extends State<NodeDraggableBuilder>
    with AutomaticKeepAliveClientMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Node>('node', widget.node));
    properties.add(DiagnosticsProperty<Widget?>('child', widget.child));
    properties.add(DiagnosticsProperty<TreeConfiguration>(
        'configuration', widget.configuration));
    properties.add(DiagnosticsProperty<int>('depth', widget.depth));
    properties.add(
        DiagnosticsProperty<NodeComponentBuilder>('builder', widget.builder));
    properties.add(DiagnosticsProperty<bool>('isDragging', _isDragging));
    properties.add(DiagnosticsProperty<NodeDragGestures>('gestures', gestures));
  }

  @override
  bool get wantKeepAlive => isDragging;

  bool get isDragging => _isDragging;
  bool _isDragging = false;

  NodeDragGestures get gestures => widget.builder.buildDragGestures(
        ComponentContext(
          depth: widget.depth,
          nodeContext: context,
          node: widget.node,
          details: null,
          wrapWithDragGestures: wrapWithDragAndDropWidgets,
          extraArgs: widget.configuration.extraArgs,
        ),
      );

  set isDragging(bool value) {
    if (value == _isDragging) return;

    if (context.mounted && mounted) {
      setState(() {
        _isDragging = value;
        updateKeepAlive();
      });
    } else {
      _isDragging = value;
    }
  }

  void _endDrag() {
    isDragging = false;
  }

  void onDragStarted() {
    isDragging = true;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset cursorPosition = renderBox.localToGlobal(Offset.zero);
    DraggableListener.of(context).dragListener
      ..globalPosition = cursorPosition
      ..localPosition = null
      ..draggedNode = widget.node;
    gestures.onDragStart?.call(cursorPosition, widget.node);
  }

  void onDragUpdate(DragUpdateDetails details) {
    DraggableListener.of(context).dragListener
      ..globalPosition = details.globalPosition
      ..localPosition = details.localPosition
      ..draggedNode = widget.node;
    gestures.onDragUpdate?.call(details);
  }

  void onDraggableCanceled(Velocity velocity, Offset point) {
    _endDrag();
    DraggableListener.of(context).dragListener
      ..globalPosition = null
      ..localPosition = null
      ..draggedNode = null;
    gestures.onDragCanceled?.call(velocity, point);
  }

  void onDragCompleted() {
    _endDrag();
    DraggableListener.of(context).dragListener
      ..globalPosition = null
      ..localPosition = null
      ..draggedNode = null;
    gestures.onDragCompleted?.call(widget.node);
  }

  @override
  void dispose() {
    isDragging = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.node is! DragAndDropMixin ||
        !widget.node.cast<DragAndDropMixin>().isDraggable() ||
        !widget.configuration.activateDragAndDropFeature) {
      return widget.child;
    }

    if (widget.configuration.draggableConfigurations.preferLongPressDraggable ||
        widget.configuration.draggableConfigurations.longPressDelay > 0) {
      return LongPressDraggable<Node>(
        data: widget.node,
        maxSimultaneousDrags: 1,
        onDragStarted: onDragStarted,
        onDragUpdate: onDragUpdate,
        onDraggableCanceled: onDraggableCanceled,
        onDragEnd: gestures.onDragEnd,
        onDragCompleted: () => gestures.onDragCompleted?.call(widget.node),
        feedback: widget.configuration.draggableConfigurations
            .buildDragFeedbackWidget(widget.node),
        axis: widget.configuration.draggableConfigurations.axis,
        childWhenDragging: widget
            .configuration.draggableConfigurations.childWhenDraggingBuilder
            ?.call(
          widget.node,
        ),
        dragAnchorStrategy: widget
            .configuration.draggableConfigurations.childDragAnchorStrategy,
        feedbackOffset:
            widget.configuration.draggableConfigurations.feedbackOffset,
        delay: Duration(
            milliseconds:
                widget.configuration.draggableConfigurations.longPressDelay),
        child: widget.child,
      );
    }

    return Draggable<Node>(
      data: widget.node,
      maxSimultaneousDrags: 1,
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDraggableCanceled: onDraggableCanceled,
      onDragEnd: gestures.onDragEnd,
      onDragCompleted: () => gestures.onDragCompleted?.call(widget.node),
      dragAnchorStrategy:
          widget.configuration.draggableConfigurations.childDragAnchorStrategy,
      feedback:
          widget.configuration.draggableConfigurations.buildDragFeedbackWidget(
        widget.node,
      ),
      axis: widget.configuration.draggableConfigurations.axis,
      childWhenDragging: widget
          .configuration.draggableConfigurations.childWhenDraggingBuilder
          ?.call(
        widget.node,
      ),
      feedbackOffset:
          widget.configuration.draggableConfigurations.feedbackOffset,
      child: widget.child,
    );
  }
}
