import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

typedef CustomLinesPainterBuilder = CustomPainter Function(
  Node node,
  Node? lastChild,
  double heightWidget,
  double? offsetX,
);

const int kDefaultExpandDelay = 625;

/// Contains all the common arguments used
/// by the [DragNodeController] during dragging gestures
class DragArgs {
  final Offset? offset;
  final Node? node;
  final Node? targetNode;

  DragArgs({
    required this.offset,
    required this.node,
    required this.targetNode,
  });
}

/// Contains all necessary configurations to handle
/// custom behaviors and common operations into the tree
/// such as moving a node, drag and drop, selecting,
/// inserting, building custom nodes
@immutable
class TreeConfiguration {
  /// Decide if should show the amount
  /// of the nodes into the CompositeTreeNode
  /// item
  final bool showNodesDeeperAmount;

  /// If this is false, then drag and drop feature
  /// wont work
  final bool activateDragAndDropFeature;

  /// If the current device is Android or IOS the
  /// items will be wrapped by [LongPressDraggable] instead
  /// [Draggable] widget
  final bool preferLongPressDraggable;

  /// Determine if the root section will be displayed
  ///
  /// this sections is used to insert any node into level zero on
  /// the tree
  final bool useRootSection;

  /// Decides if the limiter lines in every [CompositeTreeNode]
  /// must be showed or removed
  ///
  /// These lines are used to make more easy to the users
  /// know the limit of that [CompositeTreeNode] from the other nodes
  ///
  /// _Just works with default implementation_
  final bool paintItemLines;

  /// Decides how will be the **style** when draw the implementation of lines painter
  ///
  /// _Just works with default implementation_
  final Paint? customPaint;

  /// Compute where will be painted (in horizontal direction) the default line
  /// node implementation
  final double Function(double nodeIndent, Node node)?
      customComputelinesPainterOffsetX;
  final CustomLinesPainterBuilder? customLinesPainter;

  /// let us add a new way to compute the indent of the nodes
  final double Function(Node node)? customComputeNodeIndentByLevel;

  /// This key is used to avoid rebuild or remove the state of the NodeContainer
  /// unnecessarily
  final PageStorageKey<String>? Function(Node node)? containerWidgetKey;

  /// This key is used to avoid rebuild or remove the state of the LeafNode
  /// unnecessarily
  final PageStorageKey<String>? Function(Node node)? leafWidgetKey;

  /// A basic builder for the feedback that is used by [Draggable] and [LongPressDraggable] widgets
  final Widget Function(Node node) buildFeedback;
  final Widget Function(Node node, DragArgs object)? buildSectionBetweenNodes;
  final Widget Function(Node node)? buildChildWhileDragging;
  final Widget Function(NodeContainer? parent, List<Node> children)?
      buildCustomChildren;

  /// Contains all necessary configs to the CompositeTreeNode widget
  final ContainerConfiguration containerConfiguration;
  final LeafConfiguration leafConfiguration;
  final Widget? onDetectEmptyRoot;

  /// If the user have his dragged node
  /// above a [CompositeTreeNode] then
  /// a timer will start to know if the
  /// [CompositeTreeNode] should be expanded
  /// and this defines the delay
  ///
  /// By default the delay is computed
  /// by [milliseconds] and is [625]
  final int autoExpandOnDragAboveNodeDelay;

  /// This section is drawed when the user drags the node
  /// outside of other nodes (like outside of the tree)
  final Widget Function(DragArgs)? rootTargetToDropSection;
  final ScrollPhysics? physics;

  /// These are the gestures that are used just when [useRootSection] is true
  final NodeDragGestures? rootGestures;

  const TreeConfiguration({
    required this.leafConfiguration,
    required this.containerConfiguration,
    required this.buildFeedback,
    required this.buildSectionBetweenNodes,
    required this.useRootSection,
    required this.preferLongPressDraggable,
    required this.activateDragAndDropFeature,
    required this.paintItemLines,
    this.rootGestures,
    this.autoExpandOnDragAboveNodeDelay = kDefaultExpandDelay,
    this.showNodesDeeperAmount = false,
    this.customComputeNodeIndentByLevel,
    this.customLinesPainter,
    this.customComputelinesPainterOffsetX,
    this.customPaint,
    this.buildChildWhileDragging,
    this.rootTargetToDropSection,
    this.physics,
    this.buildCustomChildren,
    this.onDetectEmptyRoot,
    this.containerWidgetKey,
    this.leafWidgetKey,
  });
}
