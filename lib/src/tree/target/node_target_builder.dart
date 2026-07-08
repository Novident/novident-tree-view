import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// [NodeTargetBuilder] handles drag-and-drop operations for tree nodes.
@Deprecated('Use NodeDragAndDropBuilder instead. '
    'This widget will be removed in a future release.')
class NodeTargetBuilder extends StatefulWidget {
  /// Creates a drag target builder for tree nodes
  const NodeTargetBuilder({
    required this.builder,
    required this.configuration,
    required this.owner,
    required this.depth,
    required this.node,
    required this.index,
    this.child,
    super.key,
  });

  /// Configuration settings for the tree view
  final TreeConfiguration configuration;
  final Widget? child;
  final int depth;
  final Node node;
  final int index;
  final NodeComponentBuilder builder;

  /// The container that owns and manages this node
  final NodeContainer owner;

  @override
  State<NodeTargetBuilder> createState() => _NodeTargetBuilderState();
}

class _NodeTargetBuilderState extends State<NodeTargetBuilder> {
  @override
  Widget build(BuildContext context) {
    // Delegate to the unified builder (drag-only mode — no DragTarget
    // wrapping here, as the caller already composes it).
    return NodeDragAndDropBuilder(
      node: widget.node,
      builder: widget.builder,
      configuration: widget.configuration,
      depth: widget.depth,
      index: widget.index,
      owner: widget.owner,
      child: widget.child,
    );
  }
}
