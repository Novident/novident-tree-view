import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// Enables nodes to participate in drag-and-drop operations within the tree
///
/// Provides granular control over both drag initiation and drop acceptance
/// behavior for individual nodes in the hierarchy
mixin DragAndDropMixin {
  /// Determines if this node can initiate a drag operation
  ///
  /// Return `true` to allow dragging from this node
  bool isDraggable();

  /// Determines if this node can act as a drop target
  ///
  /// Return `true` to allow other nodes to be dropped onto this node
  bool isDropTarget();

  /// Determines if other nodes be inserted into the node
  ///
  /// Return `true` to allow other nodes to be dropped onto this node
  bool isDropIntoAllowed();

  /// Validates if a dragged node can be dropped at specific position
  ///
  /// - [draggedNode]: Node being dragged that want to be inserted into/below/above this
  /// - [dropPosition]: Target position relative to this node (above/inside/below)
  ///
  /// Return `true` to allow the drop operation at specified position
  bool isDropPositionValid(Node draggedNode, DragHandlerPosition dropPosition);
}
