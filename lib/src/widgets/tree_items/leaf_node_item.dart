import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import '../../entities/enums/drag_handler_position.dart';
import '../../entities/node/node.dart';
import '../../entities/tree_node/tree_node.dart';
import '../../utils/compute_padding_by_level.dart';
import '../../utils/context_util_ext.dart';
import '../tree/config/tree_configuration.dart';
import '../tree/extension/context_tree_ext.dart';

import '../../controller/drag_node_controller.dart';
import '../../entities/tree_node/composite_tree_node.dart';
import '../../entities/tree_node/leaf_tree_node.dart';

class LeafTreeNodeItemView extends StatefulWidget {
  final LeafTreeNode leafNode;
  final CompositeTreeNode? parent;
  final TreeConfiguration configuration;
  const LeafTreeNodeItemView({
    required this.leafNode,
    required this.parent,
    required this.configuration,
    super.key,
  });

  @override
  State<LeafTreeNodeItemView> createState() => _LeafTreeNodeItemViewState();
}

class _LeafTreeNodeItemViewState extends State<LeafTreeNodeItemView> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('parent', widget.parent));
    properties.add(DiagnosticsProperty('leaf', widget.leafNode));
  }

  @override
  Widget build(BuildContext context) {
    final DragNodeController dragNodeController = context.watchDrag();
    final bool isDragging = dragNodeController.node != null;
    final Offset? offset = context.globalPaintBounds;
    // this is the leafNode view
    Widget child = LeafTreeNodeItem(
      leafNode: widget.leafNode,
      configuration: widget.configuration,
      parent: widget.parent,
    );
    if (widget.configuration.leafConfiguration.wrapper != null) {
      child = widget.configuration.leafConfiguration.wrapper!.call(child);
    }
    return Column(
      children: [
        // above logic
        if (widget.configuration.useBetweenNodesSectionDropzone)
          ListenableBuilder(
            listenable: dragNodeController,
            builder: (BuildContext context, Widget? child) {
              if (offset == null || !isDragging) return const SizedBox.shrink();
              final dragObject = dragNodeController.object;
              // check if the user is dragging the node exactly at this node
              final isThisNode = dragObject.targetNode != null && dragObject.targetNode?.id == widget.leafNode.id;
              // check if the node that is dragged by the user is not a child before of this node
              final draggedNodeIsNotBackChild =
                  widget.parent?.backChild(widget.leafNode.node, false)?.id != dragObject.node?.id ||
                      widget.parent?.backChild(widget.leafNode.node, false) == null;
              // check if the offset is positioned exactly between the nodes to show it
              final isOffsetEffective = ((dragObject.offset?.dy ?? 18) - 18) <= offset.dy;
              final shouldShowBetweenNodeSection = isThisNode && draggedNodeIsNotBackChild && isOffsetEffective;
              if (shouldShowBetweenNodeSection) {
                return DragTarget<TreeNode>(
                  onWillAcceptWithDetails: (DragTargetDetails<TreeNode> details) {
                    if (details.data.id == widget.leafNode.id) return false;
                    if (widget.configuration.customDragGestures?.customLeafOnWillAcceptWithDetails != null) {
                      return widget.configuration.customDragGestures!.customLeafOnWillAcceptWithDetails!(
                        details,
                        widget.leafNode,
                        widget.parent,
                        DragHandlerPosition.betweenNodes,
                      );
                    }
                    return true;
                  },
                  onAcceptWithDetails: (DragTargetDetails<TreeNode> details) async {
                    if (widget.configuration.customDragGestures?.customLeafOnAcceptWithDetails != null) {
                      widget.configuration.customDragGestures!.customLeafOnAcceptWithDetails!(
                        details,
                        widget.leafNode,
                        widget.parent,
                        DragHandlerPosition.betweenNodes,
                      );
                    }
                    if (!widget.configuration.overrideDefaultActions) {
                      final data = details.data;
                      if (data is CompositeTreeNode) {
                        final canMoveDir = await canMove(data);
                        if (!canMoveDir) return;
                      }
                      final Node currentNodeAtLevel =
                          widget.leafNode.node.copyWith(level: widget.leafNode.node.level, id: details.data.id);
                      context.readTree().insertAbove(
                            data.copyWith(
                              node: currentNodeAtLevel,
                              nodeParent: widget.leafNode.nodeParent,
                            ),
                            widget.leafNode.id,
                          );
                    }
                  },
                  builder: (BuildContext context, List<TreeNode?> accepted, List<dynamic> rejected) =>
                      widget.configuration.buildSectionBetweenNodes.call(widget.leafNode, dragObject),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        if (!widget.leafNode.canDrag() || !widget.configuration.activateDragAndDropFeature) child,
        if ((Platform.isMacOS || Platform.isLinux || Platform.isWindows) &&
            widget.leafNode.canDrag() &&
            widget.configuration.activateDragAndDropFeature)
          Draggable<LeafTreeNode>(
            data: widget.leafNode,
            onDragStarted: () => context.readDrag().setDraggedNode = widget.leafNode,
            onDragEnd: (DraggableDetails details) => context.readDrag().setDraggedNode = null,
            onDragUpdate: (DragUpdateDetails details) {
              context.readDrag().setOffset = details.globalPosition;
              context.readDrag().setDraggedNode = widget.leafNode;
            },
            onDragCompleted: () => context.readDrag().setDraggedNode = null,
            childWhenDragging: widget.configuration.buildChildWhileDragging?.call(widget.leafNode),
            onDraggableCanceled: (Velocity velocity, Offset offset) => context.readDrag().setDraggedNode = null,
            feedback: widget.configuration.buildFeedback(widget.leafNode),
            child: child,
          ),
        if ((Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) &&
            widget.leafNode.canDrag() &&
            widget.configuration.activateDragAndDropFeature)
          LongPressDraggable<LeafTreeNode>(
            data: widget.leafNode,
            onDragStarted: () => context.readDrag().setDraggedNode = widget.leafNode,
            childWhenDragging: widget.configuration.buildChildWhileDragging?.call(widget.leafNode),
            onDragEnd: (DraggableDetails details) => context.readDrag().setDraggedNode = null,
            onDragUpdate: (DragUpdateDetails details) {
              context.readDrag().setOffset = details.globalPosition;
              context.readDrag().setDraggedNode = widget.leafNode;
            },
            onDragCompleted: () => context.readDrag().setDraggedNode = null,
            onDraggableCanceled: (Velocity velocity, Offset offset) => context.readDrag().setDraggedNode = null,
            feedback: widget.configuration.buildFeedback(widget.leafNode),
            child: child,
          ),
      ],
    );
  }

  Future<bool> canMove(CompositeTreeNode data) async {
    final bool existDocNode = data.existNodeWhere((TreeNode file) => file.id == widget.leafNode.id);
    return !existDocNode;
  }
}

class LeafTreeNodeItem extends StatelessWidget {
  const LeafTreeNodeItem({
    super.key,
    required this.leafNode,
    required this.parent,
    required this.configuration,
  });

  final LeafTreeNode leafNode;
  final TreeConfiguration configuration;
  final CompositeTreeNode? parent;

  @override
  Widget build(BuildContext context) {
    final Offset? offset = context.globalPaintBounds;
    final provider = context.watchTree();
    final isSelected = leafNode.id == provider.visualSelection?.id;
    return DragTarget<TreeNode>(
      onMove: (details) {
        if (details.data.id == leafNode.id) {
          context.readDrag()
            ..setDraggedNode = null
            ..setOffset = null
            ..setTargetNode = null;
          return;
        }
        if (offset != null) {
          context.readDrag()
            ..setDraggedNode = details.data
            ..setTargetNode = leafNode;
          return;
        }
        context.readDrag()
          ..setDraggedNode = null
          ..setOffset = null
          ..setTargetNode = null;
      },
      // we use this to let the dragged object be updates even if it
      // is dragged into a LeafTreeNode, but this never let to the LeafTreeNode
      // go into another LeafTreeNode
      onWillAcceptWithDetails: (details) {
        if (details.data is! Draggable) return false;
        return true;
      },
      builder: (context, candidateData, rejectedData) => Padding(
        padding: configuration.leafConfiguration.padding,
        child: InkWell(
          splashColor: configuration.leafConfiguration.onTapSplashColor,
          splashFactory: configuration.leafConfiguration.splashFactory,
          borderRadius: configuration.leafConfiguration.borderSplashRadius ?? BorderRadius.circular(10),
          customBorder: configuration.leafConfiguration.customSplashBorder,
          onSecondaryTap: configuration.leafConfiguration.onSecundaryTap == null
              ? null
              : () => configuration.leafConfiguration.onSecundaryTap?.call(leafNode, context),
          onDoubleTap: configuration.leafConfiguration.onDoubleTap == null
              ? null
              : () => configuration.leafConfiguration.onDoubleTap?.call(leafNode, context),
          hoverColor: configuration.leafConfiguration.onHoverColor,
          canRequestFocus: false,
          mouseCursor: configuration.leafConfiguration.mouseCursor,
          onHover: (onHover) => configuration.leafConfiguration.onHover?.call(leafNode, onHover, context),
          onTap: () {
            context.readTree().setVisualSelection(leafNode);
            if (!configuration.overrideDefaultActions)
              configuration.leafConfiguration.onTap?.call(leafNode, context);
          },
          child: Container(
            key: configuration.leafWidgetKey?.call(leafNode),
            decoration: configuration.leafConfiguration.leafBoxDecoration(leafNode, isSelected, false),
            height: configuration.leafConfiguration.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LeafNodeHeader(
                  leafNode: leafNode,
                  configuration: configuration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LeafNodeHeader extends StatelessWidget {
  final LeafTreeNode leafNode;
  final TreeConfiguration configuration;
  const LeafNodeHeader({
    super.key,
    required this.leafNode,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    final existExpandableButton = configuration.compositeConfiguration.showExpandableButton ||
        configuration.compositeConfiguration.expandableIconConfiguration?.customExpandableWidget != null;
    final indent = (configuration.customComputeNodeIndentByLevel?.call(leafNode) ??
        (configuration.customComputeNodeIndentByLevel != null
            ? configuration.customComputeNodeIndentByLevel?.call(leafNode)
            : existExpandableButton
                ? computePaddingForLeaf(leafNode.level)
                : computePaddingForLeafWithoutExpandable(leafNode.level)))!;
    final trailing = configuration.leafConfiguration.trailing?.call(leafNode, indent, context);
    return Row(
      children: <Widget>[
        configuration.leafConfiguration.leading(leafNode, indent, context),
        configuration.leafConfiguration.content(leafNode, indent, context),
        if (trailing != null) trailing,
      ],
    );
  }
}
