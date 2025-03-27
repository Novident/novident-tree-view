import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/controller/drag_node_controller.dart';
import 'package:novident_tree_view/src/utils/platform_utils.dart';
import 'package:novident_tree_view/src/utils/platforms_utils.dart';
import 'package:novident_tree_view/src/widgets/tree_items/simple_node_builder.dart';
import '../../tree/provider/drag_provider.dart';

/// Represents the [NodeContainer] into the Tree
/// that contains all its children and can be expanded
/// or closed
class NodeContainerTile extends ConsumerStatefulWidget {
  /// The [ContainerTreeNode] item
  final NodeContainer nodeContainer;

  /// This is a helper to the current indent for the children
  /// to make more easy for the user watch the children from
  /// a [NodeContainer]
  final double extraLeftIndent;

  final TreeConfiguration configuration;
  const NodeContainerTile({
    required this.nodeContainer,
    required this.configuration,
    super.key,
    this.extraLeftIndent = 0,
  });

  @override
  ConsumerState<NodeContainerTile> createState() => _NodeContainerTileState();
}

class _NodeContainerTileState extends ConsumerState<NodeContainerTile> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('owner', widget.nodeContainer.owner));
    properties.add(DiagnosticsProperty('container', widget.nodeContainer));
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
      listenable: widget.nodeContainer,
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
                      dragController.targetNode?.id == widget.nodeContainer.id;
                  // check if the node that is dragged by the user is not a child before of this node
                  bool draggedNodeIsNotBackChild = childBeforeThis(
                            widget.nodeContainer.owner!,
                            widget.nodeContainer.level,
                            widget.nodeContainer.id,
                            false,
                          )?.id !=
                          dragController.node?.id ||
                      childBeforeThis(
                            widget.nodeContainer.owner!,
                            widget.nodeContainer.level,
                            widget.nodeContainer.id,
                            false,
                          ) ==
                          null;
                  // check if the offset is positioned exactly between the nodes to show it
                  bool shouldShowBetweenNodeSection =
                      isThisNode && draggedNodeIsNotBackChild && isOffsetEffective;
                  if (shouldShowBetweenNodeSection) {
                    return DragTarget<Node>(
                        onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
                          if (widget.nodeContainer.id == details.data.id) return false;
                          NodeDragGestures? dragGestures = widget
                              .configuration.nodeGestures
                              .call(widget.nodeContainer);
                          return dragGestures.onWillAcceptWithDetails(
                            details,
                            widget.nodeContainer,
                            widget.nodeContainer.owner,
                            DragHandlerPosition.betweenNodes,
                          );
                        },
                        onAcceptWithDetails: (DragTargetDetails<Node> details) async {
                          NodeDragGestures? dragGestures = widget
                              .configuration.nodeGestures
                              .call(widget.nodeContainer);
                          dragGestures.onAcceptWithDetails(
                            details,
                            widget.nodeContainer,
                            widget.nodeContainer.owner,
                            DragHandlerPosition.betweenNodes,
                          );
                          return;
                        },
                        builder: (BuildContext context, List<Node?> accepted,
                                List<dynamic> rejected) =>
                            widget.configuration.nodeSectionBuilder.call(
                              widget.nodeContainer,
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
            _NodeContainerExpandableTile(
              key: Key("container-key ${widget.nodeContainer.id}"),
              files: widget.nodeContainer.children,
              extraLeftIndent: widget.extraLeftIndent,
              nodeContainer: widget.nodeContainer,
              configuration: widget.configuration,
              owner: widget.nodeContainer.owner,
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

class _NodeContainerExpandableTile extends ConsumerStatefulWidget {
  const _NodeContainerExpandableTile({
    required this.nodeContainer,
    required this.files,
    required this.configuration,
    required this.extraLeftIndent,
    super.key,
    this.owner,
  });

  final double extraLeftIndent;
  final TreeConfiguration configuration;
  final NodeContainer nodeContainer;
  final NodeContainer? owner;
  final List<Node> files;

  @override
  ConsumerState<_NodeContainerExpandableTile> createState() =>
      _NodeContainerExpandableTileState();
}

class _NodeContainerExpandableTileState
    extends ConsumerState<_NodeContainerExpandableTile> with TickerProviderStateMixin {
  Timer? timer = null;

  @override
  void dispose() {
    if (mounted) {
      timer?.cancel();
      timer = null;
    }
    super.dispose();
  }

  void _startTimerToExpandDir({bool cancel = false}) {
    if (cancel) {
      timer?.cancel();
      timer = null;
      return;
    }
    // avoid start the timer if the NodeContainer is already
    // expanded
    if (widget.nodeContainer.isExpanded) return;
    bool? isActive = timer?.isActive;
    if (timer == null || (isActive != null && !isActive)) {
      timer = Timer(
        Duration(milliseconds: widget.configuration.dragOverNodeAutoExpandDelay),
        () {
          widget.configuration.onTryOpen(widget.nodeContainer);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    final Offset? offset = result?.$1;
    final double indent = widget.configuration.leftNodeIndent.call(widget.nodeContainer) +
        widget.extraLeftIndent;
    final Widget child = widget.configuration.nodeBuilder(widget.nodeContainer, indent);
    final double height = widget.configuration.nodeHeight(widget.nodeContainer);
    final NodeDragGestures dragGestures =
        widget.configuration.nodeGestures(widget.nodeContainer);
    return Container(
      key: PageStorageKey<String>(
        '${widget.nodeContainer.runtimeType}-key ${widget.nodeContainer.id}',
      ),
      child: CustomPaint(
        painter: !widget.configuration.shouldPaintHierarchyLines
            ? null
            : widget.configuration.customLinesPainter?.call(
                  widget.nodeContainer,
                  widget.owner?.children.lastOrNull,
                  indent + getCorrectMultiplierByPlatform,
                ) ??
                HierarchyLinePainter(
                  nodeContainer: widget.nodeContainer,
                  fullHeightForContainer: height,
                  customOffsetX: widget
                      .configuration.computeHierarchyLinePainterHorizontalOffset
                      ?.call(
                    indent,
                    widget.nodeContainer,
                  ),
                  shouldPaintHierarchyLines:
                      widget.configuration.shouldPaintHierarchyLines,
                  lastChild: widget.owner?.children.lastOrNull,
                  hierarchyLinePainter: widget.configuration.hierarchyLineStyle?.call(
                    widget.nodeContainer,
                    leftIndent: widget.extraLeftIndent,
                  ),
                  configuration: widget.configuration,
                  indent: indent,
                ),
        isComplex: false,
        willChange: false,
        child: Column(
          children: <Widget>[
            DragTarget<Node>(
              onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
                return dragGestures.onWillAcceptWithDetails(
                  details,
                  widget.nodeContainer,
                  widget.owner,
                  DragHandlerPosition.intoNode,
                );
              },
              onAcceptWithDetails: (DragTargetDetails<Node> details) {
                dragGestures.onAcceptWithDetails(
                  details,
                  widget.nodeContainer,
                  widget.owner,
                  DragHandlerPosition.intoNode,
                );
                return;
              },
              onLeave: (Node? data) {
                _startTimerToExpandDir(cancel: true);
              },
              onMove: (DragTargetDetails<Node> details) {
                _startTimerToExpandDir();
                if (details.data.id == widget.nodeContainer.id &&
                    details.data.runtimeType == widget.nodeContainer.runtimeType) {
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
                      ..setTargetNode = widget.nodeContainer;
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
            ),
            // we will need to avoid pass objects that can be modified during build
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
                  final Node node = widget.nodeContainer.children.elementAt(index);
                  if (node is! NodeContainer) {
                    return SimpleNodeBuilder(
                      node: node,
                      configuration: widget.configuration,
                      extraLeftIndent: widget.extraLeftIndent,
                    );
                  } else
                    return NodeContainerTile(
                      nodeContainer: node,
                      configuration: widget.configuration,
                      extraLeftIndent: widget.extraLeftIndent,
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required BuildContext ctx,
    required double indent,
    required Widget child,
  }) {
    if (!widget.nodeContainer.canDrag() ||
        !widget.configuration.activateDragAndDropFeature) {
      return child;
    }

    Widget feedback =
        widget.configuration.buildDragFeedbackWidget.call(widget.nodeContainer);
    if (!widget.configuration.preferLongPressDraggable) {
      return Draggable(
        feedback: feedback,
        maxSimultaneousDrags: 1,
        data: widget.nodeContainer,
        onDragStarted: () {
          ref.read(dragControllerProviderState.notifier).update((
            DragNodeController controller,
          ) {
            controller..setDraggedNode = widget.nodeContainer;
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
              ..setDraggedNode = widget.nodeContainer;
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
          widget.nodeContainer,
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
      data: widget.nodeContainer,
      onDragStarted: () {
        ref.read(dragControllerProviderState.notifier).update((
          DragNodeController controller,
        ) {
          controller..setDraggedNode = widget.nodeContainer;
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
            ..setDraggedNode = widget.nodeContainer;
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
      childWhenDragging:
          widget.configuration.buildDraggingChildWidget?.call(widget.nodeContainer),
      maxSimultaneousDrags: 1,
      feedback: feedback,
      child: child,
    );
  }
}
