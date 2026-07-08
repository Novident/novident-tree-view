import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

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
@Deprecated('Use NodeDragAndDropBuilder instead. '
    'This widget will be removed in a future release.')
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
    required this.index,
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

  final int index;

  /// The tree node that is going to be provided to [Draggable.data].
  final Node node;

  @override
  State<NodeDraggableBuilder> createState() => _TreeDraggableState();
}

class _TreeDraggableState extends State<NodeDraggableBuilder> {
  @override
  Widget build(BuildContext context) {
    // Delegate to the unified builder.
    // We don't have an owner here (legacy API), so we use the node's owner.
    return NodeDragAndDropBuilder(
      node: widget.node,
      builder: widget.builder,
      configuration: widget.configuration,
      depth: widget.depth,
      index: widget.index,
      owner: widget.node.owner!,
      child: widget.child,
    );
  }
}
