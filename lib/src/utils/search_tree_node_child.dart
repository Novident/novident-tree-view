import '../entities/enums/search_order.dart';
import '../entities/node/node.dart';
import '../entities/tree_node/composite_tree_node.dart';
import '../entities/tree_node/tree_node.dart';

/// Search any child into any [CompositeTreeNode]
/// and set the strategy to customize how the search 
/// will get your node 
TreeNode? searchChild(
    CompositeTreeNode compositeNode, Node target, SearchStrategy order) {
  for (int i = 0; i < compositeNode.length; i++) {
    final node = compositeNode.elementAt(i);
    if (node.node.id == target.id) {
      if (order == SearchStrategy.back) {
        // theres no a sibling before of this child
        if (i == 0) return null;
        return compositeNode.elementAt(i - 1);
      }
      if (order == SearchStrategy.next) {
        // theres no a sibling after of this child
        if ((i + 1) >= compositeNode.length) return null;
        return compositeNode.elementAt(i + 1);
      }
      if (order == SearchStrategy.target) return node;
      if (order == SearchStrategy.first && node is CompositeTreeNode)
        return node.first;
      if (order == SearchStrategy.last && node is CompositeTreeNode)
        return node.last;
    } else if (node is CompositeTreeNode && node.isNotEmpty) {
      final foundedNode = searchChild(node, target, order);
      if (foundedNode != null) return foundedNode;
    }
  }
  return null;
}
