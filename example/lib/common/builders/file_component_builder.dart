import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/default_configurations/file_widget.dart';
import 'package:example/common/entities/file.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:example/common/extensions/num_ext.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class FileComponentBuilder extends NodeComponentBuilder {
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
        whenInside: () => const Border(),
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
        child: FileTile(
          file: node.asFile,
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
      makeTappable: true,
      decoration: BoxDecoration(
        color: controller.selectedNode?.id == node.id
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
  NodeDragGestures buildDragGestures(ComponentContext context) {
    final TreeController controller =
        context.extraArgs['controller'] as TreeController;
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
        final Node target = details.targetNode;
        details.mapDropPosition<void>(
          whenAbove: () {
            final NodeContainer parent = target.owner as NodeContainer;
            final NodeContainer dragParent =
                details.draggedNode.owner as NodeContainer;
            dragParent.removeWhere(
              (n) => n.id == details.draggedNode.id,
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
                propagateNotifications: true,
              );
            }
          },
          whenInside: () {},
          whenBelow: () {
            final NodeContainer parent = target.owner as NodeContainer;
            final NodeContainer dragParent =
                details.draggedNode.owner as NodeContainer;
            dragParent.removeWhere(
              (n) => n.id == details.draggedNode.id,
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
                (index + 1).exactByLimit(
                  parent.length,
                ),
                details.draggedNode,
                propagateNotifications: true,
              );
            }
          },
          ignoreInsideZone: true,
        );
        return;
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool validate(Node node) => node is File;
}
