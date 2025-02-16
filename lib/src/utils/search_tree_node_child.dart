import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';
import 'package:meta/meta.dart';

import '../entities/node/node_details.dart';
import '../entities/enums/search_order.dart';
import '../entities/node/node.dart';

@internal
@experimental

/// Search any child into any [NodeContainer]
/// and set the strategy to customize how the search
/// will get your node
Node? searchChild(
    NodeContainer compositeNode, NodeDetails target, SearchStrategy order) {
  for (int i = 0; i < compositeNode.length; i++) {
    Node node = compositeNode.elementAt(i);
    if (node.details.id == target.id) {
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
      if (order == SearchStrategy.first && node is NodeContainer)
        return node.first;
      if (order == SearchStrategy.last && node is NodeContainer)
        return node.last;
    } else if (node is NodeContainer && node.isNotEmpty) {
      Node? foundedNode = searchChild(node, target, order);
      if (foundedNode != null) return foundedNode;
    }
  }
  return null;
}
