import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/default_configurations/directory_widget.dart';
import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class DirectoryComponentBuilder extends NodeComponentBuilder {
  @override
  Widget build(ComponentContext context) {
    final Node node = context.node;
    Decoration? decoration;
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context.nodeContext).colorScheme.outline,
      width: 2.0,
    );

    if (context.details != null) {
      // Add a border to indicate in which portion of the target's height
      // the dragging node will be inserted.
      decoration = BoxDecoration(
        border: context.details?.mapDropPosition<BoxBorder?>(
          whenAbove: () => Border(top: borderSide),
          whenInside: () => Border.fromBorderSide(borderSide),
          whenBelow: () => Border(bottom: borderSide),
        ),
      );
    }

    return Container(
      decoration: decoration,
      child: AutomaticNodeIndentation(
        node: node,
        child: DirectoryTile(
          onTap: () {
            node.asDirectory.openOrClose();
          },
          directory: node.asDirectory,
          controller: context.extraArgs['controller'],
        ),
      ),
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    final TreeController controller =
        context.extraArgs['controller'] as TreeController;
    final Node node = context.node;
    return NodeConfiguration(
      makeTappable: false,
      decoration: BoxDecoration(
        color: controller.selectedNode == node
            ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
            : null,
      ),
      onTap: (BuildContext context) {
        if (node is Root) return;
        controller.selectNode(node);
      },
    );
  }

  @override
  NodeDragGestures buildGestures(ComponentContext context) {
    final Node node = context.node;
    final TreeController controller =
        context.extraArgs['controller'] as TreeController;
    return NodeDragGestures(
      onWillAcceptWithDetails: (
        NovDragAndDropDetails<Node>? details,
        DragTargetDetails<Node> dragDetails,
        Node target,
        Node? parent,
      ) {
        return details?.draggedNode != node;
      },
      onAcceptWithDetails: (
        NovDragAndDropDetails<Node>? details,
        Node target,
        Node? parent,
      ) {
        if (details != null) {
          details.mapDropPosition<void>(
            whenAbove: () {},
            whenInside: () {
              if (target is File) {
                return;
              }
              controller.insertAt(node, target.id);
            },
            whenBelow: () {},
          );
          return;
        }
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool validate(Node node) => node is Directory;
}
