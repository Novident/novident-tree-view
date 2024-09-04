import 'package:flutter/material.dart';

import '../entities/tree_node/composite_tree_node.dart';
import '../entities/tree_node/leaf_tree_node.dart';
import '../entities/tree_node/tree_node.dart';
import '../widgets/tree/config/tree_configuration.dart';
import '../widgets/tree_items/composite_node_item.dart';
import '../widgets/tree_items/leaf_node_item.dart';

// TODO: we need to a add custom widgets implementation
/// Transform a list of nodes into a list of widgets
/// used by the tree to do possible the common
/// actions into the tree
List<Widget> preloadTree({
  required CompositeTreeNode? parent,
  required List<TreeNode> files,
  required TreeConfiguration config,
}) {
  final List<Widget> tree = <Widget>[];
  for (int i = 0; i < files.length; i++) {
    final TreeNode file = files.elementAt(i);
    if (file is LeafTreeNode) {
      tree.add(
        LeafTreeNodeItemView(
          leafNode: file,
          parent: parent,
          configuration: config,
        ),
      );
    } else if (file is CompositeTreeNode) {
      tree.add(
        CompositeTreeNodeItemView(
          parent: parent,
          compositeNode: file,
          configuration: config,
          findFirstAncestorParent: () => parent,
        ),
      );
    }
  }
  return tree;
}
