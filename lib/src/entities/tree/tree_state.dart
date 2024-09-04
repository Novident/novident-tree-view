import '../node/node.dart';
import '../tree_node/tree_node.dart';

/// Represents a simple state
/// of the tree
class TreeState {
  final Node node;
  final List<TreeNode> children;

  TreeState({
    required this.node,
    required this.children,
  });

  @override
  String toString() {
    return 'TreeState: $node | Children: $children';
  }
}
