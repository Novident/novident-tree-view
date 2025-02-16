import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/controller/drag_node_controller.dart';
import '../../tree/provider/drag_provider.dart';

/// Represents the [NodeContainer] into the Tree
/// that contains all its children and can be expanded
/// or closed
class NodeContainerTile extends ConsumerStatefulWidget {
  /// The [ContainerTreeNode] item
  final NodeContainer nodeContainer;

  /// The owner of this [NodeContainer]
  final NodeContainer? owner;

  /// This is a helper to the current indent for the children
  /// to make more easy for the user watch the children from
  /// a [NodeContainer]
  final double extraLeftIndent;

  final TreeConfiguration configuration;
  const NodeContainerTile({
    required this.nodeContainer,
    required this.owner,
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
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties.add(DiagnosticsProperty('container', widget.nodeContainer));
  }

  /// We use this to calculate correctly the offset where should
  /// be displayed the between nodes section
  double _getCorrectEffectiveOffsetCalculationByPlatform() {
    return isMobile ? 10 : 7.5;
  }

  @override
  Widget build(BuildContext context) {
    TreeController treeController = context.readTree();
    bool isDragging = ref.watch(isDraggingANodeProvider);
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    Offset? offset = result?.$1;
    return CompositedTransformTarget(
      link: widget.nodeContainer.layer,
      child: ListenableBuilder(
        listenable: widget.nodeContainer,
        builder: (BuildContext ctx, Widget? child) {
          return Column(
            children: <Widget>[
              // above dropable section
              if (widget.configuration.buildSectionBetweenNodes != null)
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    DragNodeController dragController =
                        ref.watch(dragControllerProviderState);
                    double? targetOffset = dragController.offset?.dy;
                    if (offset == null || !isDragging || targetOffset == null)
                      return const SizedBox.shrink();
                    // Check if the current offset of the dragged node is valid to show between section
                    bool isOffsetEffective = targetOffset -
                            _getCorrectEffectiveOffsetCalculationByPlatform() <=
                        offset.dy;
                    // check if the user is dragging the node exactly at this node
                    bool isThisNode = dragController.targetNode != null &&
                        dragController.targetNode?.id ==
                            widget.nodeContainer.id;
                    // check if the node that is dragged by the user is not a child before of this node
                    bool draggedNodeIsNotBackChild = widget.owner
                                ?.childBeforeThis(
                                    widget.nodeContainer.details, false)
                                ?.id !=
                            dragController.node?.id ||
                        widget.owner?.childBeforeThis(
                                widget.nodeContainer.details, false) ==
                            null;
                    // check if the offset is positioned exactly between the nodes to show it
                    bool shouldShowBetweenNodeSection = isThisNode &&
                        draggedNodeIsNotBackChild &&
                        isOffsetEffective;
                    if (shouldShowBetweenNodeSection) {
                      return DragTarget<Node>(
                          onWillAcceptWithDetails:
                              (DragTargetDetails<Node> details) {
                            if (details.data is! MakeDraggable) return false;
                            if (widget.nodeContainer.id == details.data.id)
                              return false;
                            NodeDragGestures? dragGestures = widget
                                .configuration
                                .containerConfiguration
                                .dragGestures;
                            if (dragGestures != null &&
                                dragGestures.onWillAcceptWithDetails != null) {
                              return dragGestures.onWillAcceptWithDetails!(
                                details,
                                widget.nodeContainer,
                                widget.owner,
                                DragHandlerPosition.betweenNodes,
                              );
                            }
                            return true;
                          },
                          onAcceptWithDetails:
                              (DragTargetDetails<Node> details) async {
                            NodeDragGestures? dragGestures = widget
                                .configuration
                                .containerConfiguration
                                .dragGestures;
                            if (dragGestures != null &&
                                dragGestures.onAcceptWithDetails != null) {
                              dragGestures.onAcceptWithDetails!(
                                details,
                                widget.nodeContainer,
                                widget.owner,
                                DragHandlerPosition.betweenNodes,
                              );
                              return;
                            }
                            Node data = details.data;
                            if (data is NodeContainer) {
                              bool canMoveDir = await canMove(data);
                              if (!canMoveDir) return;
                            }
                            NodeDetails nodeDetails =
                                widget.nodeContainer.details.copyWith(
                                    level: widget.nodeContainer.details.level,
                                    id: data.details.id,
                                    owner: widget.nodeContainer.owner);
                            treeController.insertAbove(
                              data.copyWith(details: nodeDetails),
                              widget.nodeContainer.id,
                              removeIfNeeded: true,
                            );
                          },
                          builder: (BuildContext context, List<Node?> accepted,
                                  List<dynamic> rejected) =>
                              widget.configuration.buildSectionBetweenNodes!
                                  .call(
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
                key: Key("composite-util-key ${widget.nodeContainer.id}"),
                files: widget.nodeContainer.children,
                extraLeftIndent: widget.extraLeftIndent,
                nodeContainer: widget.nodeContainer,
                configuration: widget.configuration,
                owner: widget.owner,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> canMove(NodeContainer data) async {
    if (widget.nodeContainer.details.level < data.details.level) {
      return true;
    }
    bool existNode =
        widget.nodeContainer.existNodeWhere((Node file) => file.id == data.id);
    if (!existNode) {
      //Verify if this nodeContainer is a child of the data. If is true, means the document is a sub child of data source
      bool existDocNode = data
          .existNodeWhere((Node file) => file.id == widget.nodeContainer.id);
      return !existDocNode;
    }
    return !existNode;
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
    extends ConsumerState<_NodeContainerExpandableTile>
    with TickerProviderStateMixin {
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
        Duration(
            milliseconds: widget.configuration.autoExpandOnDragAboveNodeDelay),
        () {
          widget.nodeContainer.openOrClose(forceOpen: true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    Offset? offset = result?.$1;
    Size size = MediaQuery.sizeOf(context);
    TreeController provider = context.readTree();
    bool showExpandableButton =
        widget.configuration.containerConfiguration.showDefaultExpandableButton;
    Widget? customExpandableButton = widget.configuration.containerConfiguration
        .expandableIconConfiguration?.customExpandableWidget
        ?.call(
      widget.nodeContainer,
      _tryOpenOrCloseContainer,
    );
    double indent = widget.configuration.customComputeNodeIndentByLevel
            ?.call(widget.nodeContainer) ??
        (showExpandableButton
            ? computePaddingForContainer(widget.nodeContainer.level)
            : computePaddingForContainerWithoutExpandable(
                widget.nodeContainer.level));
    indent = indent + widget.extraLeftIndent;
    Widget? trailing = widget.configuration.containerConfiguration.trailing
        ?.call(widget.nodeContainer, indent, context);
    return Container(
      key: PageStorageKey<String>(
          '${widget.nodeContainer.runtimeType}-key ${widget.nodeContainer.id}'),
      child: CustomPaint(
        painter: DepthLinesPainter(
          widget.nodeContainer,
          widget.configuration.containerConfiguration.height,
          widget.configuration.customComputelinesPainterOffsetX
              ?.call(indent, widget.nodeContainer),
          widget.configuration.paintItemLines,
          widget.nodeContainer.lastOrNull,
          widget.configuration.customPaint,
          widget.configuration,
          indent,
        ),
        isComplex: true,
        child: Column(
          children: <Widget>[
            DragTarget<Node>(
              onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
                Node data = details.data;
                NodeDragGestures? dragGestures =
                    widget.configuration.containerConfiguration.dragGestures;
                if (dragGestures != null &&
                    dragGestures.onWillAcceptWithDetails != null) {
                  return dragGestures.onWillAcceptWithDetails!(
                    details,
                    widget.nodeContainer,
                    widget.owner,
                    DragHandlerPosition.intoNode,
                  );
                }
                if (data is LeafNode) {
                  return widget.nodeContainer.id != data.details.owner;
                }
                if (data is NodeContainer && widget.nodeContainer.id == data.id)
                  return false;
                return true;
              },
              onAcceptWithDetails: (DragTargetDetails<Node> details) {
                NodeDragGestures? dragGestures =
                    widget.configuration.containerConfiguration.dragGestures;
                if (dragGestures != null &&
                    dragGestures.onAcceptWithDetails != null) {
                  dragGestures.onAcceptWithDetails!(
                    details,
                    widget.nodeContainer,
                    widget.owner,
                    DragHandlerPosition.intoNode,
                  );
                  return;
                }
                Node data = details.data;
                if (data is NodeContainer) {
                  bool canMoveDir = canMove(data);
                  if (!canMoveDir) return;
                }
                NodeDetails nodeDetails = widget.nodeContainer.details.copyWith(
                    level: widget.nodeContainer.details.level + 1,
                    id: details.data.details.id);
                context.readTree().insertAt(
                      details.data.copyWith(details: nodeDetails),
                      widget.nodeContainer.id,
                      removeIfNeeded: true,
                    );
              },
              onLeave: (Node? data) {
                _startTimerToExpandDir(cancel: true);
              },
              onMove: (DragTargetDetails<Node> details) {
                _startTimerToExpandDir();
                if (details.data.id == widget.nodeContainer.id &&
                    details.data.runtimeType ==
                        widget.nodeContainer.runtimeType) {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setDraggedNode = null
                      ..setOffset = null
                      ..setTargetNode = null;
                    return DragNodeController.byController(
                        controller: controller);
                  });
                  return;
                }
                if (offset != null) {
                  ref
                      .read(dragControllerProviderState.notifier)
                      .update((DragNodeController controller) {
                    controller
                      ..setDraggedNode = details.data
                      ..setTargetNode = widget.nodeContainer;
                    return DragNodeController.byController(
                        controller: controller);
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
                  return DragNodeController.byController(
                      controller: controller);
                });
              },
              builder: (BuildContext context, List<Node?> candidateData,
                  List<dynamic> rejectedData) {
                return ValueListenableBuilder(
                    valueListenable: provider.selection,
                    builder: (BuildContext ctx, Node? value, _) {
                      bool isSelected = widget.nodeContainer.id == value?.id;
                      Widget expandableButton = !showExpandableButton
                          ? const SizedBox.shrink()
                          : InkWell(
                              customBorder: const RoundedRectangleBorder(
                                side: BorderSide(
                                    style: BorderStyle.none, color: Colors.red),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              onTap: _tryOpenOrCloseContainer,
                              mouseCursor: widget.configuration
                                  .containerConfiguration.expandableMouseCursor,
                              child: widget.configuration.containerConfiguration
                                      .expandableIconConfiguration?.iconBuilder
                                      ?.call(widget.nodeContainer, context) ??
                                  SizedBox(
                                    height: widget.configuration
                                            .containerConfiguration.height -
                                        20,
                                    width: 33,
                                    child: Icon(
                                      widget.nodeContainer.isExpanded
                                          ? Icons.arrow_drop_down_rounded
                                          : Icons.arrow_right_rounded,
                                      color: isSelected &&
                                              widget.nodeContainer.isExpanded
                                          ? Colors.white
                                          : null,
                                      size: 25,
                                    ),
                                  ),
                            );
                      Widget child = SizedBox(
                        height:
                            widget.configuration.containerConfiguration.height,
                        child: Padding(
                          padding: widget
                              .configuration.containerConfiguration.padding,
                          child: MouseRegion(
                            cursor: widget
                                .configuration.containerConfiguration.cursor,
                            child: InkWell(
                              splashColor: widget.configuration
                                  .containerConfiguration.onTapSplashColor,
                              enableFeedback: false,
                              autofocus: false,
                              splashFactory: widget.configuration
                                  .containerConfiguration.splashFactory,
                              canRequestFocus: false,
                              borderRadius: widget
                                      .configuration
                                      .containerConfiguration
                                      .borderSplashRadius ??
                                  BorderRadius.circular(10),
                              customBorder: widget.configuration
                                  .containerConfiguration.customSplashBorder,
                              onSecondaryTap: widget
                                          .configuration
                                          .containerConfiguration
                                          .onSecundaryTap ==
                                      null
                                  ? null
                                  : () => widget.configuration
                                      .containerConfiguration.onSecundaryTap
                                      ?.call(widget.nodeContainer, context),
                              onDoubleTap: widget.configuration
                                          .containerConfiguration.onDoubleTap ==
                                      null
                                  ? null
                                  : () => widget.configuration
                                      .containerConfiguration.onDoubleTap
                                      ?.call(widget.nodeContainer, context),
                              hoverColor: widget.configuration
                                  .containerConfiguration.onHoverColor,
                              onTap: () {
                                widget
                                    .configuration.containerConfiguration.onTap
                                    ?.call(widget.nodeContainer, context);
                                if (widget.configuration.containerConfiguration
                                        .onTap ==
                                    null) {
                                  context
                                      .readTree()
                                      .selectNode(widget.nodeContainer);
                                }
                              },
                              child: Container(
                                decoration: widget.configuration
                                    .containerConfiguration.boxDecoration
                                    .call(widget.nodeContainer),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(right: 3),
                                        width: size.width * 0.70,
                                        child: Row(
                                          children: <Widget>[
                                            // left indent
                                            // and expandable button
                                            if (customExpandableButton == null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: indent, right: 5),
                                                child: customExpandableButton ??
                                                    expandableButton,
                                              ),
                                            if (!showExpandableButton &&
                                                customExpandableButton != null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: indent + 1, right: 5),
                                                child: customExpandableButton,
                                              ),
                                            // leading
                                            widget.configuration
                                                .containerConfiguration.leading
                                                .call(widget.nodeContainer,
                                                    indent, context),
                                            // content child => center
                                            widget.configuration
                                                .containerConfiguration.content
                                                .call(widget.nodeContainer,
                                                    indent, context),
                                            // trailing
                                            if (trailing != null) trailing
                                          ],
                                        ),
                                      ),
                                    ),
                                    // trailing
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );

                      if (widget.configuration.containerConfiguration.wrapper !=
                          null) {
                        child = widget
                            .configuration.containerConfiguration.wrapper!
                            .call(child);
                      }

                      if (!widget.nodeContainer.canDrag() ||
                          !widget.configuration.activateDragAndDropFeature) {
                        return child;
                      }

                      Widget feedback = widget.configuration
                          .buildFeedback(widget.nodeContainer);
                      if (!widget.configuration.preferLongPressDraggable) {
                        return Draggable(
                          feedback: feedback,
                          maxSimultaneousDrags: 1,
                          data: widget.nodeContainer,
                          onDragStarted: () {
                            ref
                                .read(dragControllerProviderState.notifier)
                                .update((
                              DragNodeController controller,
                            ) {
                              controller..setDraggedNode = widget.nodeContainer;
                              return DragNodeController.byController(
                                  controller: controller);
                            });
                            ref.read(isDraggingANodeProvider.notifier).state =
                                true;
                          },
                          onDragUpdate: (DragUpdateDetails details) {
                            ref
                                .read(dragControllerProviderState.notifier)
                                .update((DragNodeController controller) {
                              controller
                                ..setOffset = details.globalPosition
                                ..setDraggedNode = widget.nodeContainer;
                              return DragNodeController.byController(
                                  controller: controller);
                            });
                            ref.read(isDraggingANodeProvider.notifier).state =
                                true;
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
                            ref.read(isDraggingANodeProvider.notifier).state =
                                false;
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
                            ref.read(isDraggingANodeProvider.notifier).state =
                                false;
                          },
                          childWhenDragging: widget
                              .configuration.buildChildWhileDragging
                              ?.call(widget.nodeContainer),
                          onDraggableCanceled:
                              (Velocity velocity, Offset offset) {
                            ref
                                .read<StateController<bool>>(
                                    isDraggingANodeProvider.notifier)
                                .state = false;
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
                              return DragNodeController.byController(
                                  controller: controller);
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
                          ref
                              .read(dragControllerProviderState.notifier)
                              .update((DragNodeController controller) {
                            controller..setDraggedNode = widget.nodeContainer;
                            return DragNodeController.byController(
                                controller: controller);
                          });
                          ref.read(isDraggingANodeProvider.notifier).state =
                              true;
                        },
                        onDragUpdate: (DragUpdateDetails details) {
                          ref
                              .read(dragControllerProviderState.notifier)
                              .update((DragNodeController controller) {
                            controller
                              ..setOffset = details.globalPosition
                              ..setDraggedNode = widget.nodeContainer;
                            return DragNodeController.byController(
                                controller: controller);
                          });
                          ref.read(isDraggingANodeProvider.notifier).state =
                              true;
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
                          ref.read(isDraggingANodeProvider.notifier).state =
                              false;
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
                          ref.read(isDraggingANodeProvider.notifier).state =
                              false;
                        },
                        onDraggableCanceled:
                            (Velocity velocity, Offset offset) {
                          ref.read(isDraggingANodeProvider.notifier).state =
                              false;
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
                        },
                        childWhenDragging: widget
                            .configuration.buildChildWhileDragging
                            ?.call(widget.nodeContainer),
                        maxSimultaneousDrags: 1,
                        feedback: feedback,
                        child: child,
                      );
                    });
              },
            ),
            // we will need to avoid pass objects that can be modified during build
            widget.configuration.buildCustomChildren?.call(
                  widget.nodeContainer.copyWith(),
                  List<Node>.unmodifiable(widget.nodeContainer.children),
                ) ??
                Visibility(
                  visible: widget.nodeContainer.isExpanded,
                  maintainSize: false,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    itemCount: widget.nodeContainer.length,
                    itemBuilder: (BuildContext context, int index) {
                      Node file = widget.nodeContainer.elementAt(index);
                      if (file is LeafNode) {
                        return LeafNodeTile(
                          singleNode: file,
                          owner: null,
                          extraLeftIndent: widget.configuration
                                  .containerConfiguration.childrenLeftIndent +
                              widget.extraLeftIndent,
                          configuration: widget.configuration,
                        );
                      } else
                        return NodeContainerTile(
                          owner: widget.owner,
                          nodeContainer: file as NodeContainer,
                          configuration: widget.configuration,
                          extraLeftIndent: widget.configuration
                                  .containerConfiguration.childrenLeftIndent +
                              widget.extraLeftIndent,
                          // there's no parent
                        );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _tryOpenOrCloseContainer() {
    widget.nodeContainer.openOrClose(forceOpen: true);
  }

  bool canMove(NodeContainer data) {
    if (widget.nodeContainer.details.level < data.details.level) {
      return true;
    }
    bool existNode =
        widget.nodeContainer.existNodeWhere((Node file) => file.id == data.id);
    if (!existNode) {
      //Verify if this nodeContainer is a child of the data. If is true, means the document is a sub child of data source
      bool existDocNode = data
          .existNodeWhere((Node file) => file.id == widget.nodeContainer.id);
      return !existDocNode;
    }
    return !existNode;
  }
}
