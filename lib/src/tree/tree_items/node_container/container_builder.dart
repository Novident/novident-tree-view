import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/tree_items/leaf_node/leaf_node_builder.dart';

/// Represents the [NodeContainer] into the Tree
/// that contains all its children and can be expanded
/// or closed
class ContainerBuilder extends StatefulWidget {
  /// The [ContainerTreeNode] item
  final Node nodeContainer;

  /// The owner of this [NodeContainer]
  final Node owner;

  final TreeConfiguration configuration;

  ContainerBuilder({
    required this.nodeContainer,
    required this.owner,
    required this.configuration,
    super.key,
  })  : assert(
          nodeContainer.isChildrenContainer,
          'the container($nodeContainer) at level ${nodeContainer.level} is not valid to be '
          'rendered as a node with children. '
          'Please, ensure that the property '
          '[isChildrenContainer] is always return true',
        ),
        assert(
          owner.isChildrenContainer,
          'The owner($owner) passed '
          'at level ${nodeContainer.level} is not '
          'valid to be an "owner" of the current node',
        );

  @override
  State<ContainerBuilder> createState() => _ContainerBuilderState();
}

class _ContainerBuilderState extends State<ContainerBuilder> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties.add(DiagnosticsProperty('container', widget.nodeContainer));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.nodeContainer,
      builder: (BuildContext ctx, Widget? child) {
        return AutomaticNodeIndentation(
          node: widget.nodeContainer,
          configuration: widget.configuration.indentConfiguration,
          child: Column(
            children: <Widget>[
              NodeDraggableBuilder(
                node: widget.nodeContainer,
                configuration: widget.configuration,
                child: NodeTargetBuilder(
                  key: Key("container-key ${widget.nodeContainer.id}"),
                  node: widget.nodeContainer,
                  configuration: widget.configuration,
                  owner: widget.owner,
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: widget.configuration.buildCustomChildren?.call(
            widget.nodeContainer,
            List<Node>.unmodifiable(widget.nodeContainer.children),
          ) ??
          Visibility(
            visible: widget.nodeContainer.isExpanded,
            maintainSize: false,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              itemCount: widget.nodeContainer.children.length,
              itemBuilder: (BuildContext context, int index) {
                final Node node =
                    widget.nodeContainer.children.elementAt(index);
                if (!node.isChildrenContainer) {
                  return LeafNodeBuilder(
                    owner: widget.owner,
                    node: node,
                    configuration: widget.configuration,
                  );
                } else
                  return ContainerBuilder(
                    owner: widget.owner,
                    nodeContainer: node,
                    configuration: widget.configuration,
                    // there's no parent
                  );
              },
            ),
          ),
    );
  }
}
