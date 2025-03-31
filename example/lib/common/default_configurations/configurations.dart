import 'dart:io';
import 'dart:math';

import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/default_configurations/directory_widget.dart';
import 'package:example/common/default_configurations/file_widget.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/internal.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

TreeConfiguration treeConfigurationBuilder(
  TreeController controller,
  BuildContext context,
) =>
    TreeConfiguration(
      activateDragAndDropFeature: true,
      addRepaintBoundaries: true,
      indentConfiguration: IndentConfiguration(
        indentPerLevel: 30,
        indentPerLevelBuilder: (Node node) {
          if (node is File) {
            return node.level == 0
                ? 1 * 30
                : (min<int>(
                          node.level,
                          IndentConfiguration.largestIndentAccepted,
                        ) *
                        30 +
                    node.level * 1.5);
          }
          return null;
        },
      ),
      scrollConfigs: ScrollConfigs(),
      onHoverContainer: (Node node) {
        if (node is NodeContainer) {
          node.asDirectory.openOrClose(forceOpen: true);
          return;
        }
      },
      draggableConfigurations: DraggableConfigurations(
        buildDragFeedbackWidget: (Node node) => Material(
          type: MaterialType.canvas,
          child: Text(
            node.runtimeType.toString() + node.level.toString(),
          ),
        ),
        childDragAnchorStrategy: (
          Draggable<Object> draggable,
          BuildContext context,
          Offset position,
        ) {
          final RenderBox renderObject =
              context.findRenderObject()! as RenderBox;
          return renderObject.globalToLocal(position);
        },
        allowAutoExpandOnHover: true,
        preferLongPressDraggable: isMobile,
      ),
      nodeDragGestures: (Node node) {
        return NodeDragGestures(
          onWillAcceptWithDetails: (
            NovDragAndDropDetails<Node>? details,
            DragTargetDetails<Node> dragDetails,
            Node? parent,
          ) =>
              details?.draggedNode != node,
          onAcceptWithDetails: (
            NovDragAndDropDetails<Node>? details,
            Node? parent,
          ) {
            if (details != null) {
              details.mapDropPosition<void>(
                //TODO: is happening. When you insert below or above
                // the controller is removing the nodes
                //
                // and, when inserting into, the loops breaks the app
                whenAbove: () {
                  controller.insertAbove(node, details.targetNode.id);
                },
                whenInside: () {
                  controller.insertAt(node, details.targetNode.id);
                },
                whenBelow: () {
                  controller.insertBelow(node, details.targetNode.id);
                },
                boundsMultiplier: 0.3,
                insideMultiplier: 1.5,
              );
              return;
            }
          },
        );
      },
      nodeConfigBuilder: (Node node) {
        return NodeConfiguration(
          makeTappable: true,
          decoration: BoxDecoration(
            color: controller.selectedNode == node
                ? Theme.of(context).primaryColor.withAlpha(50)
                : null,
          ),
          onTap: (BuildContext context) {
            if (node is Root) return;
            controller.selectNode(node);
          },
        );
      },
      nodeBuilder: (Node node, BuildContext context,
          NovDragAndDropDetails<Node>? details) {
        Decoration? decoration;
        final BorderSide borderSide = BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 2.0,
        );

        if (details != null) {
          // Add a border to indicate in which portion of the target's height
          // the dragging node will be inserted.
          decoration = BoxDecoration(
            border: details.mapDropPosition<BoxBorder?>(
              whenAbove: () => Border(top: borderSide),
              whenInside: () => Border.fromBorderSide(borderSide),
              whenBelow: () => Border(bottom: borderSide),
              boundsMultiplier: 0.3,
              insideMultiplier: 1.5,
            ),
          );
        }
        if (node.isRoot) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: decoration,
          child: AutomaticNodeIndentation(
            node: node,
            child: node.isDirectory
                ? DirectoryTile(
                    directory: node.asDirectory,
                    controller: controller,
                    onTap: () {
                      node.asDirectory.openOrClose();
                    },
                  )
                : FileTile(
                    file: node.asFile,
                    controller: controller,
                  ),
          ),
        );
      },
    );

class TrailingMenu extends StatefulWidget {
  final List<MenuItemButton> menuChildren;
  const TrailingMenu({
    super.key,
    required this.menuChildren,
  });

  @override
  State<TrailingMenu> createState() => _TrailingMenuState();
}

class _TrailingMenuState extends State<TrailingMenu> {
  final MenuController controller = MenuController();
  @override
  void dispose() {
    super.dispose();
  }

  void _openOrCloseMenu() {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: controller,
      menuChildren: widget.menuChildren,
      consumeOutsideTap: true,
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: _openOrCloseMenu,
      ),
    );
  }
}
