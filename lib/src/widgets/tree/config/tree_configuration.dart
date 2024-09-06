import 'package:flutter/material.dart';
import '../../../entities/tree_node/tree_node.dart';
import 'node_drag_gestures.dart';
import 'tree_actions.dart';
import '../../../entities/drag/dragged_object.dart';
import 'composite_configuration.dart';
import 'leaf_configuration.dart';

typedef CustomLinesPainterBuilder = CustomPainter Function(
  TreeNode node,
  TreeNode? lastChild,
  double heightWidget,
  double? offsetX,
);

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

  /// Decides if the items can be use Drag and Drop
  /// feature
  final bool canDragItems;

  /// Removes the default behavior into the tree operations
  /// like drag and drop, moving, or inserting. This means
  /// that the developer will need to implement his own
  /// logic to insert, move, or remove the nodes into
  /// the tree using [customDragGestures]
  ///
  /// Basically this remove the default
  /// behavior of the tree ops
  final bool overrideDefaultActions;

  /// Decides if the section between nodes will appears
  /// and let us to drop nodes to move above other nodes
  ///
  /// If it is false, [buildSectionBetweenNodes] wont work
  final bool useBetweenNodesSectionDropzone;

  /// If this is false, then drag and drop feature
  /// wont work
  final bool activateDragAndDropFeature;

  /// Decides if the lines in every [CompositeTreeNode]
  /// must be showed or removed
  ///
  /// These lines are used to make more easy to the users
  /// know the limit of that [CompositeTreeNode] from the other nodes
  ///
  /// _Just works with default implementation_
  final bool paintLines;

  /// Decides how will be the **style** when draw the implementation of lines painter
  ///
  /// _Just works with default implementation_
  final Paint? customPaint;

  /// Compute where will be painted (in horizontal direction) the default line
  /// node implementation
  final double Function(double nodeIndent, TreeNode node)?
      customComputelinesPainterOffsetX;
  final CustomLinesPainterBuilder? customLinesPainter;

  /// let us add a new way to compute the indent of the nodes
  final double Function(TreeNode node)? customComputeNodeIndentByLevel;

  /// This key is used to avoid rebuild or remove the state of the CompositeTreeNode
  /// unnecessarily
  final PageStorageKey<String>? Function(TreeNode node)? compositeWidgetKey;

  /// This key is used to avoid rebuild or remove the state of the LeafTreeNode
  /// unnecessarily
  final PageStorageKey<String>? Function(TreeNode node)? leafWidgetKey;

  final Widget Function(TreeNode node) buildFeedback;
  final Widget Function(TreeNode node, DraggedObject object)
      buildSectionBetweenNodes;
  final Widget Function(TreeNode node)? buildChildWhileDragging;
  final Widget Function(List<TreeNode> preloadedChildren)? buildCustomChildren;

  /// Contains all necessary configs to the CompositeTreeNode widget
  final CompositeConfiguration compositeConfiguration;
  final LeafConfiguration leafConfiguration;
  final TreeActions? treeActions;
  final NodeDragGestures? customDragGestures;
  final Widget? onDetectEmptyRoot;

  /// If the user have his dragged node
  /// above a [CompositeTreeNode] then
  /// a timer will start to know if the
  /// [CompositeTreeNode] should be expanded
  /// and this defines the delay
  ///
  /// By default the delay is computed
  /// by [milliseconds] and is [625]
  final int autoExpandOnDragOnCompositeNodeDelay;

  /// This section is drawed when the user drags the node
  /// outside of other nodes (like outside of the tree)
  final Widget Function(DraggedObject)? rootTargetToDropSection;
  final ScrollPhysics? physics;

  const TreeConfiguration({
    required this.leafConfiguration,
    required this.compositeConfiguration,
    required this.buildFeedback,
    required this.buildSectionBetweenNodes,
    this.activateDragAndDropFeature = true,
    this.useBetweenNodesSectionDropzone = true,
    this.autoExpandOnDragOnCompositeNodeDelay = 625,
    this.overrideDefaultActions = false,
    this.showNodesDeeperAmount = false,
    this.canDragItems = true,
    this.paintLines = true,
    this.customComputeNodeIndentByLevel,
    this.customLinesPainter,
    this.customComputelinesPainterOffsetX,
    this.customPaint,
    this.buildChildWhileDragging,
    this.rootTargetToDropSection,
    this.physics,
    this.customDragGestures,
    this.treeActions,
    this.compositeWidgetKey,
    this.leafWidgetKey,
    this.buildCustomChildren,
    this.onDetectEmptyRoot,
  });
}
