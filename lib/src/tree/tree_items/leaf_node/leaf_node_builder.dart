import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/indentation/automatic_node_indentation.dart';

/// Represents the leaf [Node] into the Tree
class LeafNodeBuilder extends StatefulWidget {
  /// The [ContainerTreeNode] item
  final Node node;

  /// The owner of this [NodeContainer]
  final NodeContainer<Node> owner;

  final TreeConfiguration configuration;

  const LeafNodeBuilder({
    required this.node,
    required this.owner,
    required this.configuration,
    super.key,
  });

  @override
  State<LeafNodeBuilder> createState() => _LeafNodeBuilderState();
}

class _LeafNodeBuilderState extends State<LeafNodeBuilder> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties.add(DiagnosticsProperty('${widget.node.runtimeType}', widget.node));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.node,
      builder: (BuildContext ctx, Widget? child) {
        return AutomaticNodeIndentation(
          node: widget.node,
          configuration: widget.configuration.indentConfiguration,
          child: NodeDraggableBuilder(
            node: widget.node,
            configuration: widget.configuration,
            child: NodeTargetBuilder(
              key: Key("${widget.node.runtimeType}-key ${widget.node.id}"),
              node: widget.node,
              configuration: widget.configuration,
              owner: widget.owner,
            ),
          ),
        );
      },
    );
  }
}
