import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tree_view/src/controller/tree_controller.dart';
import 'package:flutter_tree_view/src/entities/tree_node/leaf_node.dart';
import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';
import 'package:flutter_tree_view/src/extensions/num_extensions.dart';
import 'package:flutter_tree_view/src/widgets/tree/config/gestures/node_drag_gestures.dart';
import 'package:flutter_tree_view/src/widgets/tree/provider/drag_provider.dart';
import '../../../controller/drag_node_controller.dart';
import '../../../entities/enums/drag_handler_position.dart';
import '../../../entities/node/node_details.dart';
import '../../../entities/node/node.dart';
import '../../../interfaces/draggable_node.dart';
import '../../../utils/context_util_ext.dart';
import '../../../utils/platform_utils.dart';
import '../../tree/config/tree_configuration.dart';
import '../../tree/extension/context_tree_ext.dart';
import 'leaf_node_tile_header.dart';

class LeafNodeTile extends ConsumerStatefulWidget {
  final LeafNode singleNode;
  final NodeContainer? owner;
  final double extraLeftIndent;
  final TreeConfiguration configuration;
  const LeafNodeTile({
    required this.singleNode,
    required this.owner,
    required this.configuration,
    this.extraLeftIndent = 0,
    super.key,
  });

  @override
  ConsumerState<LeafNodeTile> createState() => _LeafNodeTileState();
}

class _LeafNodeTileState extends ConsumerState<LeafNodeTile> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties.add(DiagnosticsProperty('leaf', widget.singleNode));
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
    // this is the content of the tile view
    Widget child = _SingleNodeItem(
      singleNode: widget.singleNode,
      extraLeftIndent: widget.extraLeftIndent,
      configuration: widget.configuration,
      owner: widget.owner,
      ref: ref,
    );
    if (widget.configuration.leafConfiguration.wrapper != null) {
      child = widget.configuration.leafConfiguration.wrapper!.call(child);
    }
    return CompositedTransformTarget(
      link: widget.singleNode.layer,
      child: ListenableBuilder(
        listenable: widget.singleNode,
        builder: (BuildContext ctx, _) => Column(
          children: <Widget>[
            // above logic
            if (widget.configuration.nodeSectionBuilder != null)
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  DragNodeController dragNodeController =
                      ref.watch(dragControllerProviderState);
                  double? targetOffset = dragNodeController.offset?.dy;
                  if (offset == null || !isDragging || targetOffset == null)
                    return const SizedBox.shrink();
                  // Check if the current offset of the dragged node is valid to show between section
                  bool isOffsetEffective = targetOffset -
                          _getCorrectEffectiveOffsetCalculationByPlatform() <=
                      offset.dy;
                  // check if the user is dragging the node exactly at this node
                  bool isThisNode = dragNodeController.targetNode != null &&
                      dragNodeController.targetNode?.id == widget.singleNode.id;
                  // check if the node that is dragged by the user is not a child before of this node
                  bool draggedNodeIsNotBackChild = widget.owner
                              ?.childBeforeThis(
                                  widget.singleNode.details, false)
                              ?.id !=
                          dragNodeController.node?.id ||
                      widget.owner?.childBeforeThis(
                              widget.singleNode.details, false) ==
                          null;
                  // check if the offset is positioned exactly between the nodes to show it
                  bool shouldShowBetweenNodeSection = isThisNode &&
                      draggedNodeIsNotBackChild &&
                      isOffsetEffective;
                  if (shouldShowBetweenNodeSection) {
                    return DragTarget<Node>(
                        onWillAcceptWithDetails:
                            (DragTargetDetails<Node> details) {
                          NodeDragGestures? dragGestures = widget
                              .configuration.leafConfiguration.dragGestures;
                          if (dragGestures != null &&
                              dragGestures.onWillAcceptWithDetails != null) {
                            return dragGestures.onWillAcceptWithDetails!(
                              details,
                              widget.singleNode,
                              widget.owner,
                              DragHandlerPosition.betweenNodes,
                            );
                          }
                          if (details.data.id == widget.singleNode.id)
                            return false;
                          return true;
                        },
                        onAcceptWithDetails:
                            (DragTargetDetails<Node> details) async {
                          NodeDragGestures? dragGestures = widget
                              .configuration.leafConfiguration.dragGestures;
                          if (dragGestures != null &&
                              dragGestures.onAcceptWithDetails != null) {
                            return dragGestures.onAcceptWithDetails!(
                              details,
                              widget.singleNode,
                              widget.owner,
                              DragHandlerPosition.betweenNodes,
                            );
                          }
                          Node data = details.data;
                          if (data is NodeContainer) {
                            bool canMoveDir = await canMove(data);
                            if (!canMoveDir) return;
                          }
                          NodeDetails detailsOfCurrentNode =
                              widget.singleNode.details.copyWith(
                            level: widget.singleNode.details.level,
                            id: details.data.id,
                            owner: widget.singleNode.owner,
                          );
                          context.readTree().insertAbove(
                                data.copyWith(details: detailsOfCurrentNode),
                                widget.singleNode.id,
                              );
                        },
                        builder: (BuildContext context, List<Node?> accepted,
                                List<dynamic> rejected) =>
                            widget.configuration.nodeSectionBuilder!.call(
                              widget.singleNode,
                              DragArgs(
                                offset: dragNodeController.offset,
                                node: dragNodeController.node,
                                targetNode: dragNodeController.targetNode,
                              ),
                            ));
                  }
                  return const SizedBox.shrink();
                },
              ),
            if (!widget.singleNode.canDrag() ||
                !widget.configuration.activateDragAndDropFeature)
              child,
            if (!widget.configuration.preferLongPressDraggable &&
                widget.configuration.activateDragAndDropFeature)
              Draggable<LeafNode>(
                data: widget.singleNode,
                onDragStarted: () {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller..setDraggedNode = widget.singleNode;
                    return DragNodeController.byController(
                        controller: controller);
                  });
                  ref.read(isDraggingANodeProvider.notifier).state = true;
                },
                onDragUpdate: (DragUpdateDetails details) {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setOffset = details.globalPosition
                      ..setDraggedNode = widget.singleNode;
                    return DragNodeController.byController(
                        controller: controller);
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
                    return DragNodeController.byController(
                        controller: controller);
                  });
                  ref.read(isDraggingANodeProvider.notifier).state = false;
                },
                onDragCompleted: () {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setOffset = null
                      ..setDraggedNode = null
                      ..setTargetNode = null;
                    return DragNodeController.byController(
                        controller: controller);
                  });
                  ref.read(isDraggingANodeProvider.notifier).state = false;
                },
                onDraggableCanceled: (Velocity velocity, Offset offset) {
                  ref.read(isDraggingANodeProvider.notifier).state = false;
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setOffset = null
                      ..setDraggedNode = null
                      ..setTargetNode = null;
                    return DragNodeController.byController(
                        controller: controller);
                  });
                },
                childWhenDragging:
                    widget.configuration.buildDraggingChildWidget?.call(
                  widget.singleNode,
                ),
                feedback: widget.configuration
                    .buildDragFeedbackWidget(widget.singleNode),
                child: child,
              ),
            if (widget.configuration.preferLongPressDraggable &&
                widget.configuration.activateDragAndDropFeature)
              LongPressDraggable<LeafNode>(
                data: widget.singleNode,
                childWhenDragging: widget.configuration.buildDraggingChildWidget
                    ?.call(widget.singleNode),
                onDragStarted: () {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller..setDraggedNode = widget.singleNode;
                    return DragNodeController.byController(
                        controller: controller);
                  });
                  ref.read(isDraggingANodeProvider.notifier).state = true;
                },
                onDragUpdate: (DragUpdateDetails details) {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setOffset = details.globalPosition
                      ..setDraggedNode = widget.singleNode;
                    return DragNodeController.byController(
                        controller: controller);
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
                    return DragNodeController.byController(
                        controller: controller);
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
                    return DragNodeController.byController(
                        controller: controller);
                  });
                  ref.read(isDraggingANodeProvider.notifier).state = false;
                },
                onDraggableCanceled: (Velocity velocity, Offset offset) {
                  ref.read(isDraggingANodeProvider.notifier).state = false;
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setOffset = null
                      ..setDraggedNode = null
                      ..setTargetNode = null;
                    return DragNodeController.byController(
                        controller: controller);
                  });
                },
                feedback: widget.configuration
                    .buildDragFeedbackWidget(widget.singleNode),
                child: child,
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> canMove(NodeContainer data) async {
    bool existDocNode =
        data.existNodeWhere((Node file) => file.id == widget.singleNode.id);
    return !existDocNode;
  }
}

class _SingleNodeItem extends StatelessWidget {
  const _SingleNodeItem({
    required this.singleNode,
    required this.owner,
    required this.extraLeftIndent,
    required this.configuration,
    required this.ref,
  });
  final WidgetRef ref;
  final double extraLeftIndent;
  final LeafNode singleNode;
  final TreeConfiguration configuration;
  final NodeContainer? owner;

  @override
  Widget build(BuildContext context) {
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    Offset? offset = result?.$1;
    TreeController provider = context.watchTree();
    return DragTarget<Node>(
      onMove: (DragTargetDetails<Node> details) {
        if (details.data.id == singleNode.id &&
            details.data.runtimeType == singleNode.runtimeType) {
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
          ref
              .read(dragControllerProviderState.notifier)
              .update((DragNodeController controller) {
            controller
              ..setDraggedNode = details.data
              ..setTargetNode = singleNode;
            return DragNodeController.byController(controller: controller);
          });
          return;
        }
        ref
            .read(dragControllerProviderState.notifier)
            .update((DragNodeController controller) {
          controller
            ..setDraggedNode = null
            ..setOffset = null
            ..setTargetNode = null;
          return DragNodeController.byController(controller: controller);
        });
      },
      // we use this to let the dragged object be updates even if it
      // is dragged into a LeafNode, but this never let to theLeafNode
      // go into another LeafNode
      onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
        if (details.data is! MakeDraggable) return false;
        return true;
      },
      builder: (BuildContext context, List<Node?> candidateData,
              List<dynamic> rejectedData) =>
          Builder(builder: (context) {
        return Padding(
          padding: configuration.leafConfiguration.padding ?? EdgeInsets.zero,
          child: InkWell(
            enableFeedback: false,
            autofocus: false,
            splashColor: configuration.leafConfiguration.tapSplashColor,
            splashFactory: configuration.leafConfiguration.splashFactory,
            borderRadius: configuration.leafConfiguration.splashBorderRadius ??
                BorderRadius.circular(10),
            customBorder: configuration.leafConfiguration.customSplashShape,
            onSecondaryTap:
                configuration.leafConfiguration.onSecondaryTap == null
                    ? null
                    : () => configuration.leafConfiguration.onSecondaryTap
                        ?.call(singleNode, context),
            onDoubleTap: configuration.leafConfiguration.onDoubleTap == null
                ? null
                : () => configuration.leafConfiguration.onDoubleTap
                    ?.call(singleNode, context),
            hoverColor: configuration.leafConfiguration.hoverColor,
            canRequestFocus: false,
            mouseCursor: configuration.leafConfiguration.cursor,
            onHover: (bool onHover) => configuration.leafConfiguration.onHover
                ?.call(singleNode, onHover, context),
            onTap: () {
              configuration.leafConfiguration.onTap?.call(singleNode, context);
              if (configuration.leafConfiguration.onTap == null) {
                context.readTree().selectNode(singleNode);
              }
            },
            child: ValueListenableBuilder(
                valueListenable: provider.selection,
                builder: (BuildContext context, Node? node, Widget? child) {
                  return Container(
                    key: configuration.leafWidgetKey?.call(singleNode),
                    decoration:
                        configuration.leafConfiguration.boxDecoration?.call(
                      singleNode,
                    ),
                    height: configuration
                        .leafConfiguration.widgetHeight?.nullableNegative
                        ?.toDouble(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        LeafNodeTileHeader(
                          singleNode: singleNode,
                          extraLeftIndent: extraLeftIndent,
                          configuration: configuration,
                        ),
                      ],
                    ),
                  );
                }),
          ),
        );
      }),
    );
  }
}
