import 'dart:math';

import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/configurations/widgets/directory_widget.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/extensions/node_ext.dart';
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

    final NovDragAndDropDetails<Node>? details = context.details;
    if (details != null) {
      // Add a border to indicate in which portion of the target's height
      // the dragging node will be inserted.
      BoxBorder? border;
      if (Node.canMoveTo(
        node: details.draggedNode,
        target: details.targetNode,
        inside: details.exactPosition() == DragHandlerPosition.into,
      )) {
        border = context.details?.mapDropPosition<BoxBorder?>(
          whenAbove: () => Border(top: borderSide),
          whenInside: () => Border.fromBorderSide(borderSide),
          whenBelow: () => Border(bottom: borderSide),
        );
      }

      decoration = BoxDecoration(
        border: border,
        color: border == null ? null : Colors.grey.withValues(alpha: 180),
      );
    }

    return DecoratedBox(
      decoration: decoration ?? BoxDecoration(),
      position: DecorationPosition.foreground,
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
    final TreeController controller =
        context.extraArgs['controller'] as TreeController;
    return NodeDragGestures.standardDragAndDrop(
      onWillInsert: (Node node, NodeContainer owner, int level) {
        if (node is Directory) {
          node.redepthChildren(currentLevel: level);
        }
        if (node is File && controller.selection.value?.id == node.id) {
          controller.selectNode(
            node.copyWith(
              details: node.details.copyWith(owner: owner, level: level),
            ),
          );
        }
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool get useAsyncBuild => true;

  @override
  bool get cacheChildrenAfterFirstAsyncBuild => true;

  @override
  Future<List<Widget>?> buildChildrenAsync(ComponentContext context) async {
    List<Widget> children = [];
    return Future<List<Widget>>.delayed(Duration(seconds: 1), () {
      for (int i = 0; i < context.node.asDirectory.length; i++) {
        final subNode = context.node.asDirectory.elementAt(i);
        if (subNode is! NodeContainer) {
          children.add(
            LeafNodeBuilder(
              node: subNode,
              owner: context.node.asContainer,
              depth: context.node.childrenLevel,
              index: i,
            ),
          );
          continue;
        }
        children.add(
          ContainerBuilder(
            nodeContainer: subNode,
            owner: context.node.asContainer,
            depth: context.node.childrenLevel,
            index: i,
          ),
        );
      }
      return children;
    });
  }

  @override
  Widget? buildChildrenAsyncError(
    ComponentContext context,
    StackTrace? stacktrace,
    Object error,
  ) {
    return Center(
      child: Text('Error: $e'),
    );
  }

  @override
  Widget? buildChildrenAsyncPlaceholder(ComponentContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  @override
  bool validate(Node node) => node is Directory;
}
