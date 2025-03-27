import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/controller/drag_node_controller.dart';
import 'package:novident_tree_view/src/utils/platform_utils.dart';
import 'package:novident_tree_view/src/widgets/tree/provider/drag_provider.dart';

/// Represents the [Node] (usually a leaf one) into the Tree
class SimpleNodeBuilder extends ConsumerStatefulWidget {
  /// The [Node] item
  final Node node;

  /// This is a helper to the current indent for the children
  /// to make more easy for the user watch the children from
  /// a [NodeContainer]
  final double extraLeftIndent;

  final TreeConfiguration configuration;
  const SimpleNodeBuilder({
    required this.node,
    required this.configuration,
    super.key,
    this.extraLeftIndent = 0,
  });

  @override
  ConsumerState<SimpleNodeBuilder> createState() => _SimpleNodeBuilderState();
}

class _SimpleNodeBuilderState extends ConsumerState<SimpleNodeBuilder> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('container', widget.node));
  }

  /// We use this to calculate correctly the offset where should
  /// be displayed the between nodes section
  double _getCorrectEffectiveOffsetCalculationByPlatform() {
    return isMobile ? 10 : 7.5;
  }

  @override
  Widget build(BuildContext context) {
    bool isDragging = ref.watch(isDraggingANodeProvider);
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    Offset? offset = result?.$1;
    return ListenableBuilder(
      listenable: widget.node,
      builder: (BuildContext ctx, Widget? child) {
        return Column(
          children: <Widget>[
            // above dropable section
            if (widget.configuration.activateDragAndDropFeature)
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  DragNodeController dragController =
                      ref.watch(dragControllerProviderState);
                  double? targetOffset = dragController.offset?.dy;
                  if (offset == null || !isDragging || targetOffset == null)
                    return const SizedBox.shrink();
                  // Check if the current offset of the dragged node is valid to show between section
                  bool isOffsetEffective =
                      targetOffset - _getCorrectEffectiveOffsetCalculationByPlatform() <=
                          offset.dy;
                  // check if the user is dragging the node exactly at this node
                  bool isThisNode = dragController.targetNode != null &&
                      dragController.targetNode?.id == widget.node.id;
                  // check if the node that is dragged by the user is not a child before of this node
                  // check if the node that is dragged by the user is not a child before of this node
                  bool draggedNodeIsNotBackChild = childBeforeThis(
                            widget.node.owner!,
                            widget.node.level,
                            widget.node.id,
                            false,
                          )?.id !=
                          dragController.node?.id ||
                      childBeforeThis(
                            widget.node.owner!,
                            widget.node.level,
                            widget.node.id,
                            false,
                          ) ==
                          null;
                  // check if the offset is positioned exactly between the nodes to show it
                  bool shouldShowBetweenNodeSection =
                      isThisNode && draggedNodeIsNotBackChild && isOffsetEffective;
                  if (shouldShowBetweenNodeSection) {
                    return DragTarget<Node>(
                        onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
                          if (widget.node.id == details.data.id) return false;
                          NodeDragGestures? dragGestures =
                              widget.configuration.nodeGestures.call(widget.node);
                          return dragGestures.onWillAcceptWithDetails(
                            details,
                            widget.node,
                            widget.node.owner,
                            DragHandlerPosition.betweenNodes,
                          );
                        },
                        onAcceptWithDetails: (DragTargetDetails<Node> details) async {
                          NodeDragGestures? dragGestures =
                              widget.configuration.nodeGestures.call(widget.node);
                          dragGestures.onAcceptWithDetails(
                            details,
                            widget.node,
                            widget.node.owner,
                            DragHandlerPosition.betweenNodes,
                          );
                          return;
                        },
                        builder: (BuildContext context, List<Node?> accepted,
                                List<dynamic> rejected) =>
                            widget.configuration.nodeSectionBuilder.call(
                              widget.node,
                              DragArgs(
                                offset: dragController.offset,
                                node: dragController.node,
                                targetNode: dragController.targetNode,
                              ),
                            ));
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        );
      },
    );
  }

  Node? childBeforeThis(
    NodeContainer node,
    int level,
    String id,
    bool alsoInChildren, [
    int? indexNode,
  ]) {
    if (indexNode != null) {
      final element = node.children.elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode == 0) return null;
        return node.children.elementAt(indexNode - 1);
      }
    }
    for (int i = 0; i < node.children.length; i++) {
      final treeNode = node.children.elementAt(i);
      if (treeNode.id == node.id) {
        if (i - 1 == -1) return null;
        return node.children.elementAt(i - 1);
      } else if (treeNode is NodeContainer && !treeNode.isEmpty && alsoInChildren) {
        final backNode = childBeforeThis(
          treeNode,
          level,
          id,
          alsoInChildren,
          indexNode,
        );
        if (backNode != null) return backNode;
      }
    }
    return null;
  }
}

class _SimpleNodeTile extends ConsumerStatefulWidget {
  const _SimpleNodeTile({
    required this.node,
    required this.configuration,
    required this.extraLeftIndent,
    required this.owner,
  });

  final Node node;
  final NodeContainer? owner;
  final TreeConfiguration configuration;
  final double extraLeftIndent;

  @override
  ConsumerState<_SimpleNodeTile> createState() => _SimpleNodeTileState();
}

class _SimpleNodeTileState extends ConsumerState<_SimpleNodeTile> {
  @override
  Widget build(BuildContext context) {
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    final Offset? offset = result?.$1;
    final double indent =
        widget.configuration.leftNodeIndent.call(widget.node) + widget.extraLeftIndent;
    final Widget child = widget.configuration.nodeBuilder(widget.node, indent);
    final NodeDragGestures dragGestures = widget.configuration.nodeGestures(widget.node);
    return DragTarget<Node>(
      onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
        return dragGestures.onWillAcceptWithDetails(
          details,
          widget.node,
          widget.owner,
          DragHandlerPosition.intoNode,
        );
      },
      onAcceptWithDetails: (DragTargetDetails<Node> details) {
        dragGestures.onAcceptWithDetails(
          details,
          widget.node,
          widget.owner,
          DragHandlerPosition.intoNode,
        );
        return;
      },
      onMove: (DragTargetDetails<Node> details) {
        if (details.data.id == widget.node.id &&
            details.data.runtimeType == widget.node.runtimeType) {
          ref
              .read(dragControllerProviderState.notifier)
              .update((DragNodeController controller) {
            controller
              ..setDraggedNode = null
              ..setOffset = null
              ..setTargetNode = null;
            return DragNodeController.byController(controller: controller);
          });
          return;
        }
        if (offset != null) {
          ref.read(dragControllerProviderState.notifier).update((
            DragNodeController controller,
          ) {
            controller
              ..setDraggedNode = details.data
              ..setTargetNode = widget.node;
            return DragNodeController.byController(controller: controller);
          });
          return;
        }
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller
            ..setDraggedNode = null
            ..setOffset = null
            ..setTargetNode = null;
          return DragNodeController.byController(controller: controller);
        });
      },
      builder: (
        BuildContext context,
        List<Node?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return _buildTile(
          ctx: context,
          indent: indent,
          child: child,
        );
      },
    );
  }

  Widget _buildTile({
    required BuildContext ctx,
    required double indent,
    required Widget child,
  }) {
    if (!widget.node.canDrag() || !widget.configuration.activateDragAndDropFeature) {
      return child;
    }

    Widget feedback = widget.configuration.buildDragFeedbackWidget.call(widget.node);
    if (!widget.configuration.preferLongPressDraggable) {
      return Draggable(
        feedback: feedback,
        maxSimultaneousDrags: 1,
        data: widget.node,
        onDragStarted: () {
          ref.read(dragControllerProviderState.notifier).update((
            DragNodeController controller,
          ) {
            controller..setDraggedNode = widget.node;
            return DragNodeController.byController(controller: controller);
          });
          ref.read(isDraggingANodeProvider.notifier).state = true;
        },
        onDragUpdate: (DragUpdateDetails details) {
          ref
              .read(dragControllerProviderState.notifier)
              .update((DragNodeController controller) {
            controller
              ..setOffset = details.globalPosition
              ..setDraggedNode = widget.node;
            return DragNodeController.byController(controller: controller);
          });
          ref.read(isDraggingANodeProvider.notifier).state = true;
        },
        onDragEnd: (DraggableDetails details) {
          ref
              .read(dragControllerProviderState.notifier)
              .update((DragNodeController controller) {
            controller
              ..setOffset = null
              ..setTargetNode = null
              ..setDraggedNode = null;
            return DragNodeController.byController(controller: controller);
          });
          ref.read(isDraggingANodeProvider.notifier).state = false;
        },
        onDragCompleted: () {
          ref
              .read(dragControllerProviderState.notifier)
              .update((DragNodeController controller) {
            controller
              ..setOffset = null
              ..setTargetNode = null
              ..setDraggedNode = null;
            return DragNodeController.byController(controller: controller);
          });
          ref.read(isDraggingANodeProvider.notifier).state = false;
        },
        childWhenDragging: widget.configuration.buildDraggingChildWidget?.call(
          widget.node,
        ),
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          ref.read<StateController<bool>>(isDraggingANodeProvider.notifier).state = false;
          ref
              .read<StateController<DragNodeController>>(
                  dragControllerProviderState.notifier)
              .update((
            DragNodeController controller,
          ) {
            controller
              ..setOffset = null
              ..setTargetNode = null
              ..setDraggedNode = null;
            return DragNodeController.byController(controller: controller);
          });
        },
        child: child,
      );
    }
    // if preferLongPressDraggable is true, then will builder this version
    // of the drag
    return LongPressDraggable<Node>(
      data: widget.node,
      onDragStarted: () {
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller..setDraggedNode = widget.node;
          return DragNodeController.byController(controller: controller);
        });
        ref.read(isDraggingANodeProvider.notifier).state = true;
      },
      onDragUpdate: (DragUpdateDetails details) {
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller
            ..setOffset = details.globalPosition
            ..setDraggedNode = widget.node;
          return DragNodeController.byController(controller: controller);
        });
        ref.read(isDraggingANodeProvider.notifier).state = true;
      },
      onDragEnd: (DraggableDetails details) {
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller
            ..setOffset = null
            ..setTargetNode = null
            ..setDraggedNode = null;
          return DragNodeController.byController(controller: controller);
        });
        ref.read(isDraggingANodeProvider.notifier).state = false;
      },
      onDragCompleted: () {
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller
            ..setOffset = null
            ..setTargetNode = null
            ..setDraggedNode = null;
          return DragNodeController.byController(controller: controller);
        });
        ref.read(isDraggingANodeProvider.notifier).state = false;
      },
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        ref.read(isDraggingANodeProvider.notifier).state = false;
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller
            ..setOffset = null
            ..setTargetNode = null
            ..setDraggedNode = null;
          return DragNodeController.byController(controller: controller);
        });
      },
      childWhenDragging: widget.configuration.buildDraggingChildWidget?.call(widget.node),
      maxSimultaneousDrags: 1,
      rootOverlay: true,
      feedback: feedback,
      child: child,
    );
  }
}
