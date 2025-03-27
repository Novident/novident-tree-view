import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

const int kDefaultExpandDelay = 625;

typedef CustomLinesPainterBuilder = CustomPainter Function(
  Node node,
  Node? lastChild,
  double? offsetX,
);

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
  final Widget Function(Node node, double indentForLevel) nodeBuilder;
  final double Function(Node node) nodeHeight;
  final void Function(NodeContainer node) onTryOpen;

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

  /// Determines whether to display visual hierarchy lines for each [NodeContainer].
  ///
  /// When enabled, lines (e.g., node line `|` or end line `|-`) are drawn to represent the hierarchical
  /// structure of the nodes, helping users visually understand the relationships
  /// and levels within the tree.
  ///
  /// - Set to `true` to enable the hierarchy lines.
  /// - Set to `false` to disable them.
  ///
  /// **Note**: This only works with the default implementation.
  final bool shouldPaintHierarchyLines;

  /// Defines the style used to paint the hierarchy lines of a [NodeContainer].
  ///
  /// This allows customization of the appearance of the hierarchy lines, such as
  /// color, stroke width, or other [Paint] properties. If not provided, the
  /// default style will be used.
  ///
  /// Example:
  /// ```dart
  /// hierarchyLineStyle: Paint()
  ///   ..color = Colors.grey
  ///   ..strokeWidth = 1.5,
  /// ```
  ///
  /// **Note**: This only works with the default implementation.
  final Paint Function(Node node, {double? leftIndent})? hierarchyLineStyle;

  /// Computes the horizontal offset for painting the default node lines.
  ///
  /// This method determines the position (in the horizontal axis) where the
  /// lines connecting nodes will be drawn. It allows customization of the
  /// line alignment based on the node's indentation and properties.
  ///
  /// - [nodeIndent]: The current indentation level of the node.
  /// - [node]: The node for which the line offset is being calculated.
  ///
  /// Returns the horizontal offset where the line should be painted.
  ///
  /// **Note**: If not provided, the default implementation will be used.
  final double Function(double nodeIndent, Node node)?
      computeHierarchyLinePainterHorizontalOffset;
  final CustomLinesPainterBuilder? customLinesPainter;

  /// let us add a new way to compute the indent of the nodes
  final double Function(Node node) leftNodeIndent;

  /// This key is used to avoid rebuild or remove the state of the LeafNode
  /// unnecessarily
  final PageStorageKey<String>? Function(Node node)? nodeKey;

  /// Constructs the visual feedback widget displayed during a drag operation.
  ///
  /// This builder is used by [Draggable] and [LongPressDraggable] widgets to
  /// create a visual representation of the dragged node. The feedback widget
  /// is typically shown under the user's finger or cursor while dragging.
  ///
  /// - [node]: The node that is being dragged.
  /// - Returns: A widget that represents the visual feedback during the drag operation.
  final Widget Function(Node node) buildDragFeedbackWidget;

  /// Constructs a widget that appears when a node is dragged over another node.
  ///
  /// This widget is typically displayed during a drag operation to indicate
  /// where the dragged node can be inserted. When the dragged node is dropped
  /// onto this widget, it triggers the insertion of the dragged node into
  /// the corresponding position in the tree structure.
  ///
  /// - [node]: The target node over which the dragged node is hovering.
  /// - [object]: The drag-related data (e.g., the dragged node and its position).
  ///
  /// Returns a widget representing the insertion point or placeholder.
  final Widget Function(Node node, DragArgs object) nodeSectionBuilder;

  /// Constructs a widget that represents the child node during a drag event.
  ///
  /// This widget is typically used to visually indicate the child node being
  /// dragged. It can customize the appearance of the node while it is being
  /// moved, such as adding a shadow, changing opacity, or applying a preview style.
  final Widget Function(Node node)? buildDraggingChildWidget;

  final Widget? onDetectEmptyRoot;

  /// Defines the delay before automatically expanding a [NodeContainer] when a node is dragged over it.
  ///
  /// When a user drags a node over a [NodeContainer], a timer starts to determine
  /// if the container should be expanded to reveal its children. This property
  /// specifies the duration of that delay in milliseconds.
  ///
  /// - Default value: `625` milliseconds.
  ///
  /// **Note**: This behavior only applies when the dragged node is held over the [NodeContainer].
  final int dragOverNodeAutoExpandDelay;

  /// This section is drawed when the user drags the node
  /// outside of other nodes (like outside of the tree)
  final Widget Function(DragArgs)? rootTargetToDropSection;
  final ScrollPhysics? physics;

  /// These are the gestures that are used just when [useRootSection] is true
  final NodeDragGestures rootGestures;

  final NodeDragGestures Function(Node node) nodeGestures;

  const TreeConfiguration({
    required this.nodeSectionBuilder,
    required this.preferLongPressDraggable,
    required this.activateDragAndDropFeature,
    required this.shouldPaintHierarchyLines,
    required this.buildDragFeedbackWidget,
    required this.leftNodeIndent,
    required this.nodeBuilder,
    required this.onTryOpen,
    required this.nodeGestures,
    required this.nodeHeight,
    required this.rootGestures,
    this.useRootSection = false,
    this.dragOverNodeAutoExpandDelay = kDefaultExpandDelay,
    this.customLinesPainter,
    this.computeHierarchyLinePainterHorizontalOffset,
    this.hierarchyLineStyle,
    this.buildDraggingChildWidget,
    this.rootTargetToDropSection,
    this.physics,
    this.onDetectEmptyRoot,
    this.nodeKey,
  });
}
