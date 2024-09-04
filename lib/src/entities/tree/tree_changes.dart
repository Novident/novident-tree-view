import 'tree_operation.dart';
import 'tree_state.dart';

import '../tree_node/tree_node.dart';

/// Represents the change maded by the user
/// the children of this change are the nodes
/// pasted, removed, moved or inserted directly
/// into the tree
class TreeChange {
  final List<TreeNode> children;
  final TreeOperation operation;
  final TreeNode? node;

  TreeChange({
    required this.children,
    required this.operation,
    this.node,
  });

  @override
  String toString() {
    return 'Change: $node | Operation(name: ${operation.name}) | \nNodes changed: $children';
  }
}

/// Represents the changes between the before state after the
/// operation was applied and the new state with the new changes
class TreeStateChanges {
  final TreeState oldState;
  final TreeChange change;

  TreeStateChanges({
    required this.oldState,
    required this.change,
  });

  @override
  String toString() {
    return 'TreeStateChanges: $change | OldState => \n$oldState';
  }
}
