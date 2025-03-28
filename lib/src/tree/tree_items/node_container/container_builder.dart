import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/indentation/automatic_node_indentation.dart';
import 'package:novident_tree_view/src/tree/tree_items/leaf_node/leaf_node_builder.dart';

/// Represents the [NodeContainer] into the Tree
/// that contains all its children and can be expanded
/// or closed
class ContainerBuilder extends StatefulWidget {
  /// The [ContainerTreeNode] item
  final NodeContainer<Node> nodeContainer;

  /// The owner of this [NodeContainer]
  final NodeContainer<Node> owner;

  final TreeConfiguration configuration;

  const ContainerBuilder({
    required this.nodeContainer,
    required this.owner,
    required this.configuration,
    super.key,
  });

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
                Node file = widget.nodeContainer.children.elementAt(index);
                if (file is! NodeContainer) {
                  return LeafNodeBuilder(
                    owner: widget.owner,
                    node: file,
                    configuration: widget.configuration,
                  );
                } else
                  return ContainerBuilder(
                    owner: widget.owner,
                    nodeContainer: file,
                    configuration: widget.configuration,
                    // there's no parent
                  );
              },
            ),
          ),
    );
  }
}
