import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/configurations/widgets/file_widget.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/common/nodes/root.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:example/widgets/editor/editor_configuration.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class FileComponentBuilder extends NodeComponentBuilder {
  final BorderSide borderSide = BorderSide(
    color: kEditorAccent,
    width: 2.0,
  );

  final BorderSide errorBorderSide = BorderSide(
    color: Colors.redAccent,
    width: 2.0,
  );

  @override
  bool validate(Node node, int depth) => node is File;

  @override
  FileComponentBuilder clone<T extends Node>(
    T node,
    BuildContext context,
  ) {
    return FileComponentBuilder();
  }

  @override
  Widget build(ComponentContext context) {
    final TreeController controller =
        context.sharedData['controller'] as TreeController;
    return ValueListenableBuilder(
      valueListenable: controller.currentSelectedNode,
      builder: (___, selectedNode, __) {
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
                if (!(details.targetNode as DragAndDropMixin)
                    .isDropPositionValid(
                  details.draggedNode,
                  DropPosition.above,
                )) {
                  error = true;
                  return Border(top: errorBorderSide);
                }
                final int targetIndex = details.targetNode.index;
                final int draggedIndex = details.draggedNode.index;
                if (details.draggedNode.owner?.id ==
                        details.targetNode.owner?.id &&
                    details.draggedNode.level == details.targetNode.level &&
                    draggedIndex + 1 == targetIndex) {
                  error = true;
                  return Border(top: errorBorderSide);
                }
                return Border(top: borderSide);
              },
              whenInside: () => Border.fromBorderSide(borderSide),
              whenBelow: () {
                if (!(details.targetNode as DragAndDropMixin)
                    .isDropPositionValid(
                  details.draggedNode,
                  DropPosition.below,
                )) {
                  error = true;
                  return Border(bottom: errorBorderSide);
                }
                final int targetIndex = details.targetNode.index;
                final int draggedIndex = details.draggedNode.index;
                if (details.draggedNode.owner?.id ==
                        details.targetNode.owner?.id &&
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
                    : kEditorAccent.withAlpha(50),
            borderRadius: BorderRadiusDirectional.circular(5),
          );
        }

        if (decoration == null && isDragging) {
          decoration = BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(5),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: selectedNode?.id == node.id
                ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
                : null,
          ),
          child: DecoratedBox(
            decoration: decoration ?? BoxDecoration(),
            position: DecorationPosition.foreground,
            child: AutomaticNodeIndentation(
              node: node,
              child: FileTile(
                file: node.asFile,
                controller: context.sharedData['controller'],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    final TreeController controller =
        context.sharedData['controller'] as TreeController;
    final Node node = context.node;
    return NodeConfiguration(
      touchable: true,
      // add secundary tap
      onTap: (BuildContext ctx) {
        if (node is Root) return;
        setState(() {
          controller.selectNode(node);
        });
      },
    );
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
}
