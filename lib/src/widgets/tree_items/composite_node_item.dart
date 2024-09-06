import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tree_view/src/entities/enums/drag_handler_position.dart';
import 'package:flutter_tree_view/src/utils/context_util_ext.dart';
import 'package:flutter_tree_view/src/widgets/depth_lines_painter/depth_lines_painter.dart';
import 'package:flutter_tree_view/src/widgets/tree/config/tree_configuration.dart';
import 'package:flutter_tree_view/src/widgets/tree/extension/context_tree_ext.dart';
import 'package:flutter_tree_view/src/widgets/tree_items/leaf_node_item.dart';

import '../../entities/drag/dragged_object.dart';
import '../../entities/node/node.dart';
import '../../entities/tree_node/composite_tree_node.dart';
import '../../entities/tree_node/leaf_tree_node.dart';
import '../../entities/tree_node/tree_node.dart';
import '../../interfaces/draggable_node.dart' as tv;
import '../../utils/compute_padding_by_level.dart';

class CompositeTreeNodeItemView extends StatefulWidget {
  final CompositeTreeNode compositeNode;
  final CompositeTreeNode? parent;
  final CompositeTreeNode? Function() findFirstAncestorParent;
  final TreeConfiguration configuration;
  const CompositeTreeNodeItemView({
    super.key,
    required this.compositeNode,
    required this.parent,
    required this.configuration,
    required this.findFirstAncestorParent,
  });

  @override
  State<CompositeTreeNodeItemView> createState() => _CompositeTreeNodeItemViewState();
}

class _CompositeTreeNodeItemViewState extends State<CompositeTreeNodeItemView> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('parent', widget.parent));
    properties.add(DiagnosticsProperty('composite', widget.compositeNode));
  }

  @override
  Widget build(BuildContext context) {
    final dragController = context.watchDrag();
    final treeController = context.watchTree();
    final bool isDragging = dragController.isDragging;
    final Offset? offset = context.globalPaintBounds;
    return Column(
      children: <Widget>[
        // above dropeable section
        //TODO: you can see this like notion, that instead removes this from the view
        // them have a little section that just get a color when the mouse drag above it
        // if not, then just remove the color and avoid the weird resizing
        if (widget.configuration.useBetweenNodesSectionDropzone)
          ListenableBuilder(
            listenable: dragController,
            builder: (BuildContext context, Widget? child) {
              if (offset == null || !isDragging) return const SizedBox.shrink();
              final DraggedObject dragObject = dragController.object;
              // check if the user is dragging the node exactly at this node
              final isThisNode =
                  dragObject.targetNode != null && dragObject.targetNode?.id == widget.compositeNode.id;
              // check if the node that is dragged by the user is not a child before of this node
              final draggedNodeIsNotBackChild =
                  widget.parent?.backChild(widget.compositeNode.node, false)?.id != dragObject.node?.id ||
                      widget.parent?.backChild(widget.compositeNode.node, false) == null;
              // check if the offset is positioned exactly between the nodes to show it
              final isOffsetEffective = ((dragObject.offset?.dy ?? 18) - 18) <= offset.dy;
              final shouldShowBetweenNodeSection = isThisNode && draggedNodeIsNotBackChild && isOffsetEffective;
              if (shouldShowBetweenNodeSection) {
                return DragTarget<TreeNode>(
                    onWillAcceptWithDetails: (DragTargetDetails<TreeNode> details) {
                      if (details.data is! tv.Draggable) return false;
                      if (widget.compositeNode.id == details.data.id) return false;
                      if (widget.configuration.customDragGestures != null &&
                          widget.configuration.customDragGestures!.customCompositeOnWillAcceptWithDetails !=
                              null) {
                        return widget.configuration.customDragGestures!.customCompositeOnWillAcceptWithDetails!(
                          details,
                          widget.compositeNode,
                          widget.parent,
                          DragHandlerPosition.betweenNodes,
                        );
                      }
                      return true;
                    },
                    onAcceptWithDetails: (DragTargetDetails<TreeNode> details) async {
                      if (widget.configuration.customDragGestures != null &&
                          widget.configuration.customDragGestures!.customCompositeOnAcceptWithDetails != null) {
                        widget.configuration.customDragGestures!.customCompositeOnAcceptWithDetails!(
                          details,
                          widget.compositeNode,
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
                        final Node node = widget.compositeNode.node
                            .copyWith(level: widget.compositeNode.node.level, id: data.node.id);
                        treeController.insertAbove(
                          data.copyWith(
                            node: node,
                            nodeParent: widget.compositeNode.nodeParent,
                          ),
                          widget.compositeNode.id,
                          removeIfNeeded: true,
                        );
                      }
                    },
                    builder: (BuildContext context, List<TreeNode?> accepted, List<dynamic> rejected) =>
                        widget.configuration.buildSectionBetweenNodes.call(widget.compositeNode, dragObject));
              }
              return const SizedBox.shrink();
            },
          ),
        ExpandableCompositeNodeItemView(
          key: Key("composite-util-key ${widget.compositeNode.id}"),
          files: widget.compositeNode.children,
          compositeNode: widget.compositeNode,
          configuration: widget.configuration,
          parent: widget.parent,
        ),
      ],
    );
  }

  Future<bool> canMove(CompositeTreeNode data) async {
    if (widget.compositeNode.node.level < data.node.level) {
      return true;
    }
    final bool existNode = widget.compositeNode.existNodeWhere((TreeNode file) => file.id == data.id);
    if (!existNode) {
      //Verify if this compositeNode is a child of the data. If is true, means the document is a sub child of data source
      final bool existDocNode = data.existNodeWhere((TreeNode file) => file.id == widget.compositeNode.id);
      return !existDocNode;
    }
    return !existNode;
  }
}

class ExpandableCompositeNodeItemView extends StatefulWidget {
  const ExpandableCompositeNodeItemView({
    super.key,
    required this.compositeNode,
    required this.files,
    required this.configuration,
    this.parent,
  });

  final TreeConfiguration configuration;
  final CompositeTreeNode compositeNode;
  final CompositeTreeNode? parent;
  final List<TreeNode> files;

  @override
  State<ExpandableCompositeNodeItemView> createState() => _ExpandableCompositeNodeItemViewState();
}

class _ExpandableCompositeNodeItemViewState extends State<ExpandableCompositeNodeItemView>
    with TickerProviderStateMixin {
  Timer? timer = null;
  bool isDraggingAboveThis = false;

  @override
  void dispose() {
    if (mounted) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _startTimerToExpandDir({bool cancel = false}) {
    if (cancel) {
      timer?.cancel();
      return;
    }
    // avoid start the timer if the CompositeTreeNode is already
    // expanded
    if (widget.compositeNode.isExpanded) return;
    if (timer == null || timer?.isActive == false) {
      timer = Timer(
        Duration(milliseconds: widget.configuration.autoExpandOnDragOnCompositeNodeDelay),
        () {
          context
              .readTree()
              .updateNodeAt(widget.compositeNode.copyWith(isExpanded: true), widget.compositeNode.id);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Offset? offset = context.globalPaintBounds;
    final Size size = MediaQuery.sizeOf(context);
    final currentSelectedNode = context.watchTree().visualSelection;
    final isSelected = currentSelectedNode != null && currentSelectedNode.id == widget.compositeNode.id;
    final showExpandableButton = widget.configuration.compositeConfiguration.showExpandableButton;
    final customExpandableButton =
        widget.configuration.compositeConfiguration.expandableIconConfiguration?.customExpandableWidget?.call(
      widget.compositeNode,
      isSelected,
      _tryOpenOrCloseComposite,
    );
    final indent = widget.configuration.customComputeNodeIndentByLevel?.call(widget.compositeNode) ??
        (showExpandableButton
            ? computePaddingForComposite(widget.compositeNode.level)
            : computePaddingForCompositeWithoutExpandable(widget.compositeNode.level));
    final Widget? trailing =
        widget.configuration.compositeConfiguration.trailing?.call(widget.compositeNode, indent, context);
    return Container(
      color: isDraggingAboveThis ? Colors.blue.withOpacity(0.1) : null,
      key: PageStorageKey<String>('${widget.compositeNode.runtimeType}-key ${widget.compositeNode.id}'),
      child: CustomPaint(
        painter: DepthLinesPainter(
          widget.compositeNode,
          widget.configuration.compositeConfiguration.height,
          widget.configuration.customComputelinesPainterOffsetX?.call(indent, widget.compositeNode),
          widget.configuration.paintLines,
          widget.compositeNode.lastOrNull,
          widget.configuration.customPaint,
          widget.configuration,
        ),
        isComplex: true,
        child: Column(
          children: <Widget>[
            DragTarget<TreeNode>(
              onWillAcceptWithDetails: (DragTargetDetails<TreeNode> details) {
                final data = details.data;
                if (data is LeafTreeNode) {
                  return widget.compositeNode.id != data.nodeParent;
                }
                if (data is CompositeTreeNode && widget.compositeNode.id == data.id) return false;
                if (widget.configuration.customDragGestures != null &&
                    widget.configuration.customDragGestures!.customCompositeOnWillAcceptWithDetails != null) {
                  return widget.configuration.customDragGestures!.customCompositeOnWillAcceptWithDetails!(
                    details,
                    widget.compositeNode,
                    widget.parent,
                    DragHandlerPosition.intoNode,
                  );
                }
                return true;
              },
              onAcceptWithDetails: (DragTargetDetails<TreeNode> details) {
                if (widget.configuration.customDragGestures != null &&
                    widget.configuration.customDragGestures!.customCompositeOnAcceptWithDetails != null) {
                  widget.configuration.customDragGestures!.customCompositeOnAcceptWithDetails!(
                    details,
                    widget.compositeNode,
                    widget.parent,
                    DragHandlerPosition.intoNode,
                  );
                }
                if (!widget.configuration.overrideDefaultActions) {
                  final data = details.data;
                  if (data is CompositeTreeNode) {
                    final canMoveDir = canMove(data);
                    if (!canMoveDir) return;
                  }
                  final Node node = widget.compositeNode.node
                      .copyWith(level: widget.compositeNode.node.level + 1, id: details.data.node.id);
                  context.readTree().insertAt(
                        details.data.copyWith(node: node),
                        widget.compositeNode.id,
                        removeIfNeeded: true,
                      );
                }
              },
              onLeave: (data) {
                _startTimerToExpandDir(cancel: true);
              },
              onMove: (DragTargetDetails<TreeNode> details) {
                _startTimerToExpandDir();
                if (details.data.id == widget.compositeNode.id) {
                  context.readDrag()
                    ..setDraggedNode = null
                    ..setOffset = null
                    ..setTargetNode = null;
                  return;
                }
                if (offset != null) {
                  context.readDrag()
                    ..setDraggedNode = details.data
                    ..setTargetNode = widget.compositeNode;
                  return;
                }
                context.readDrag()
                  ..setDraggedNode = null
                  ..setOffset = null
                  ..setTargetNode = null;
              },
              builder: (BuildContext context, List<TreeNode?> candidateData, List<dynamic> rejectedData) {
                final expandableButton = !showExpandableButton
                    ? const SizedBox.shrink()
                    : InkWell(
                        customBorder: const RoundedRectangleBorder(
                          side: BorderSide(style: BorderStyle.none, color: Colors.red),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        onTap: _tryOpenOrCloseComposite,
                        mouseCursor: widget.configuration.compositeConfiguration.expandableMouseCursor,
                        child: widget.configuration.compositeConfiguration.expandableIconConfiguration?.iconBuilder
                                ?.call(widget.compositeNode, context) ??
                            SizedBox(
                              height: widget.configuration.compositeConfiguration.height - 20,
                              width: 33,
                              child: Icon(
                                widget.compositeNode.isExpanded
                                    ? Icons.arrow_drop_down_rounded
                                    : Icons.arrow_right_rounded,
                                color: isSelected && widget.compositeNode.isExpanded ? Colors.white : null,
                                size: 25,
                              ),
                            ),
                      );
                Widget child = SizedBox(
                  height: widget.configuration.compositeConfiguration.height,
                  child: Padding(
                    padding: widget.configuration.compositeConfiguration.padding,
                    child: MouseRegion(
                      cursor: widget.configuration.compositeConfiguration.compositeMouseCursor,
                      child: InkWell(
                        splashColor: widget.configuration.compositeConfiguration.onTapSplashColor,
                        splashFactory: widget.configuration.compositeConfiguration.splashFactory,
                        canRequestFocus: false,
                        borderRadius: widget.configuration.compositeConfiguration.borderSplashRadius ??
                            BorderRadius.circular(10),
                        customBorder: widget.configuration.compositeConfiguration.customSplashBorder,
                        onSecondaryTap: widget.configuration.compositeConfiguration.onSecundaryTap == null
                            ? null
                            : () => widget.configuration.compositeConfiguration.onSecundaryTap
                                ?.call(widget.compositeNode, context),
                        onDoubleTap: widget.configuration.compositeConfiguration.onDoubleTap == null
                            ? null
                            : () => widget.configuration.compositeConfiguration.onDoubleTap
                                ?.call(widget.compositeNode, context),
                        hoverColor: widget.configuration.compositeConfiguration.onHoverColor,
                        onTap: () {
                          widget.configuration.compositeConfiguration.onTap?.call(widget.compositeNode, context);
                          if (!widget.configuration.overrideDefaultActions) {
                            context.readTree().setVisualSelection(widget.compositeNode);
                          }
                        },
                        child: Container(
                          decoration: widget.configuration.compositeConfiguration.compositeBoxDecoration
                              .call(widget.compositeNode, isSelected, false),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(right: 3),
                                  width: size.width * 0.70,
                                  child: Row(
                                    children: [
                                      // left indent
                                      // and expandable button
                                      if (customExpandableButton == null)
                                        Padding(
                                          padding: EdgeInsets.only(left: indent, right: 5),
                                          child: customExpandableButton ?? expandableButton,
                                        ),
                                      if (!showExpandableButton && customExpandableButton != null)
                                        Padding(
                                          padding: EdgeInsets.only(left: indent + 1, right: 5),
                                          child: customExpandableButton,
                                        ),
                                      // leading
                                      widget.configuration.compositeConfiguration.leading
                                          .call(widget.compositeNode, indent, context),
                                      // content child => center
                                      widget.configuration.compositeConfiguration.content
                                          .call(widget.compositeNode, indent, context),
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

                if (widget.configuration.compositeConfiguration.wrapper != null) {
                  child = widget.configuration.compositeConfiguration.wrapper!.call(child);
                }

                if (!widget.compositeNode.canDrag() || !widget.configuration.activateDragAndDropFeature) {
                  return child;
                }

                final feedback = widget.configuration.buildFeedback(widget.compositeNode);
                if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
                  return Draggable(
                    feedback: feedback,
                    maxSimultaneousDrags: 1,
                    data: widget.compositeNode,
                    onDragStarted: () => context.readDrag().setDraggedNode = widget.compositeNode,
                    onDragUpdate: (DragUpdateDetails details) {
                      context.readDrag().setOffset = details.globalPosition;
                      context.readDrag().setDraggedNode = widget.compositeNode;
                    },
                    onDragEnd: (DraggableDetails details) => context.readDrag().setDraggedNode = null,
                    onDragCompleted: () => context.readDrag().setDraggedNode = null,
                    childWhenDragging: widget.configuration.buildChildWhileDragging?.call(widget.compositeNode),
                    onDraggableCanceled: (Velocity velocity, Offset offset) =>
                        context.readDrag().setDraggedNode = null,
                    child: child,
                  );
                }

                return LongPressDraggable<TreeNode>(
                  data: widget.compositeNode,
                  onDragStarted: () => context.readDrag().setDraggedNode = widget.compositeNode,
                  onDragUpdate: (DragUpdateDetails details) {
                    context.readDrag().setOffset = details.globalPosition;
                    context.readDrag().setDraggedNode = widget.compositeNode;
                  },
                  onDragEnd: (DraggableDetails details) => context.readDrag().setDraggedNode = null,
                  onDragCompleted: () => context.readDrag().setDraggedNode = null,
                  childWhenDragging: widget.configuration.buildChildWhileDragging?.call(widget.compositeNode),
                  onDraggableCanceled: (Velocity velocity, Offset offset) =>
                      context.readDrag().setDraggedNode = null,
                  maxSimultaneousDrags: 1,
                  feedback: feedback,
                  child: child,
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                left: widget.configuration.compositeConfiguration.childrenLeftIndent,
              ),
              child: widget.configuration.buildCustomChildren?.call(widget.compositeNode.children) ??
                  Visibility(
                    visible: widget.compositeNode.isExpanded,
                    maintainSize: false,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      itemCount: widget.compositeNode.length,
                      itemBuilder: (context, index) {
                        final TreeNode file = widget.compositeNode.elementAt(index);
                        if (file is LeafTreeNode) {
                          return LeafTreeNodeItemView(
                            leafNode: file,
                            parent: null,
                            configuration: widget.configuration,
                          );
                        } else
                          return CompositeTreeNodeItemView(
                            parent: null,
                            compositeNode: file as CompositeTreeNode,
                            configuration: widget.configuration,
                            findFirstAncestorParent: () => null,
                          );
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _tryOpenOrCloseComposite() {
    context.readTree().updateNodeAt(
          widget.compositeNode.copyWith(isExpanded: !widget.compositeNode.isExpanded),
          widget.compositeNode.id,
        );
  }

  bool canMove(CompositeTreeNode data) {
    if (widget.compositeNode.node.level < data.node.level) {
      return true;
    }
    final bool existNode = widget.compositeNode.existNodeWhere((TreeNode file) => file.id == data.id);
    if (!existNode) {
      //Verify if this compositeNode is a child of the data. If is true, means the document is a sub child of data source
      final bool existDocNode = data.existNodeWhere((TreeNode file) => file.id == widget.compositeNode.id);
      return !existDocNode;
    }
    return !existNode;
  }
}
