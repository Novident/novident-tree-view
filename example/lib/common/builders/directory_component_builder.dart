import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/default_configurations/directory_widget.dart';
import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:example/common/extensions/num_ext.dart';
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
      final border = context.details?.mapDropPosition<BoxBorder?>(
        whenAbove: () => Border(top: borderSide),
        whenInside: () => Border.fromBorderSide(borderSide),
        whenBelow: () => Border(bottom: borderSide),
      );
      decoration = BoxDecoration(
        border: border,
        color: border == null ? null : Colors.grey.withValues(alpha: 130),
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
    final TreeController controller = context.extraArgs['controller'] as TreeController;
    final Node node = context.node;
    return NodeConfiguration(
      makeTappable: true,
      decoration: BoxDecoration(
        color: controller.selectedNode == node
            ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
            : null,
      ),
      onTap: (BuildContext context) {
        node.asDirectory.openOrClose();
      },
    );
  }

  @override
  NodeDragGestures buildDragGestures(ComponentContext context) {
    final Node node = context.node;
    return NodeDragGestures(
      onWillAcceptWithDetails: (
        NovDragAndDropDetails<Node>? details,
        DragTargetDetails<Node> dragDetails,
        Node? parent,
      ) {
        return details?.draggedNode != node;
      },
      onAcceptWithDetails: (
        NovDragAndDropDetails<Node> details,
        Node? parent,
      ) {
        final TreeController controller = context.extraArgs['controller'] as TreeController;
        final Node target = details.targetNode;
        details.mapDropPosition<void>(
          whenAbove: () {
            final Node target = details.targetNode;
            final NodeContainer parent = target.owner as NodeContainer;
            final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
            dragParent.removeWhere(
              (n) => n.id == details.draggedNode.id,
              propagateNotifications: true,
            );
            final int index = target.index;
            if (index != -1) {
              controller.selectNode(
                details.draggedNode.copyWith(
                  details: details.draggedNode.details.copyWith(
                    level: parent.level,
                    owner: parent,
                  ),
                ),
              );
              parent.insert(
                index,
                details.draggedNode,
              );
            }
          },
          whenInside: () {
            final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
            dragParent
              ..removeWhere(
                (n) => n.id == details.draggedNode.id,
                shouldNotify: false,
              )
              ..notify(propagate: true);
              controller.selectNode(
                details.draggedNode.copyWith(
                  details: details.draggedNode.details.copyWith(
                    level: details.targetNode.level + 1,
                    owner: details.targetNode,
                  ),
                ),
              );
            (details.targetNode as NodeContainer)
                .add(details.draggedNode, propagateNotifications: true);
          },
          whenBelow: () {
            final NodeContainer parent = target.owner as NodeContainer;
            final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
            dragParent.removeWhere(
              (n) => n.id == details.draggedNode.id,
              propagateNotifications: true,
            );
            final int index = target.index;
            if (index != -1) {
              controller.selectNode(
                details.draggedNode.copyWith(
                  details: details.draggedNode.details.copyWith(
                    level: details.targetNode.level,
                    owner: parent,
                  ),
                ),
              );
              parent.insert(
                (index + 1).exactByLimit(
                  parent.length,
                ),
                details.draggedNode,
              );
            }
          },
        );
        return;
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool validate(Node node) => node is Directory;
}
