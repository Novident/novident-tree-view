import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/configurations/widgets/directory_widget.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class DirectoryComponentBuilder extends NodeComponentBuilder {
  final BorderSide borderSide = BorderSide(
    color: Colors.blueAccent,
    width: 2.0,
  );

  final BorderSide errorBorderSide = BorderSide(
    color: Colors.redAccent,
    width: 2.0,
  );

  @override
  Widget build(ComponentContext context) {
    final Node node = context.node;
    Decoration? decoration;

    final NovDragAndDropDetails<Node>? details = context.details;
    if (details != null) {
      // Add a border to indicate in which portion of the target's height
      // the dragging node will be inserted.
      BoxBorder? border;
      bool error = false;
      if (Node.canMoveTo(
        node: details.draggedNode,
        target: details.targetNode,
        inside: details.exactPosition() == DropPosition.inside,
      )) {
        border = context.details?.mapDropPosition<BoxBorder?>(
          whenAbove: () {
            if (!(details.targetNode as DragAndDropMixin).isDropPositionValid(
              details.draggedNode,
              DropPosition.above,
            )) {
              error = true;
              return Border(top: errorBorderSide);
            }
            final int targetIndex = details.targetNode.index;
            final int draggedIndex = details.draggedNode.index;
            if (details.draggedNode.owner?.id == details.targetNode.owner?.id &&
                details.draggedNode.level == details.targetNode.level &&
                draggedIndex + 1 == targetIndex) {
              error = true;
              return Border(top: errorBorderSide);
            }
            return Border(top: borderSide);
          },
          whenInside: () => Border.fromBorderSide(borderSide),
          whenBelow: () {
            if (!(details.targetNode as DragAndDropMixin).isDropPositionValid(
              details.draggedNode,
              DropPosition.below,
            )) {
              error = true;
              return Border(bottom: errorBorderSide);
            }
            final int targetIndex = details.targetNode.index;
            final int draggedIndex = details.draggedNode.index;
            if (details.draggedNode.owner?.id == details.targetNode.owner?.id &&
                details.draggedNode.level == details.targetNode.level &&
                targetIndex + 1 == draggedIndex) {
              error = true;
              return Border(bottom: errorBorderSide);
            }
            return Border(bottom: borderSide);
          },
        );
      }

      decoration = BoxDecoration(
        border: border,
        color: border == null
            ? null
            : error
                ? Colors.redAccent.withAlpha(50)
                : Colors.blueAccent.withAlpha(50),
        borderRadius: BorderRadiusDirectional.circular(5),
      );
    }

    if (decoration == null && isDragging) {
      decoration = BoxDecoration(
        color: isDragging ? Colors.grey.withAlpha(30) : null,
        borderRadius: BorderRadiusDirectional.circular(5),
      );
    }
    return DecoratedBox(
      decoration: decoration ?? BoxDecoration(),
      position: DecorationPosition.foreground,
      child: Container(
        color: isDragging ? Colors.grey.withAlpha(30) : null,
        child: AutomaticNodeIndentation(
          node: node,
          child: DirectoryTile(
            onTap: () {
              node.asDirectory.openOrClose();
            },
            directory: node.asDirectory,
            controller: context.sharedData['controller'],
            beingDragged: isDragging,
          ),
        ),
      ),
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    final TreeController controller =
        context.sharedData['controller'] as TreeController;
    final Node node = context.node;
    return NodeConfiguration(
      touchable: true,
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
  void onTryExpand(
      ComponentContext context, NovDragAndDropDetails<Node>? details) {
    final NodeContainer node = context.node as NodeContainer;
    // Don't expand if already expanded
    if (node.isExpanded) {
      return;
    }
    if ((details != null && details.exactPosition() == DropPosition.inside)) {
      node.asDirectory.openOrClose(forceOpen: true);
    }
  }

  @override
  NodeDragGestures buildDragGestures(ComponentContext context) {
    final TreeController controller =
        context.sharedData['controller'] as TreeController;
    return NodeDragGestures.standardDragAndDrop(
      onWillInsert: (Node node, NodeContainer owner, int level) {
        if (node is File && controller.selection.value?.id == node.id) {
          controller.selectNode(node);
        }
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool validate(Node node, int depth) => node is Directory;
}
