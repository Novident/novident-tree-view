import '../entities/tree_node/tree_node.dart';

/// An simple interfaces that gives to the Nodes
/// the ability to be dragged and dropped in some
/// node parents
mixin Draggable {
  /// Decides if the user can drag the
  /// item to drop on another side
  bool canDrag({bool isSelectingModeActive = false});
  bool canDrop({required TreeNode target});
}
