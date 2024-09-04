import 'package:flutter_tree_view/src/entities/tree_node/composite_tree_node.dart';
import 'package:flutter_tree_view/src/entities/tree_node/tree_node.dart';

import 'selectable_tree_node.dart';
import '../../interfaces/draggable_node.dart';

/// LeafTreeNode represents a simple type of node
///
/// You can see this implementation as a file from a directory
/// that can contain all type data into itself
abstract class LeafTreeNode extends SelectableTreeNode implements Draggable {
  LeafTreeNode({
    required super.node,
    required super.nodeParent,
  });

  @override
  LeafTreeNode clone();

  @override
  bool canBePressed() {
    return true;
  }

  @override
  bool canDrag({bool isSelectingModeActive = false}) {
    return true;
  }

  @override
  bool canDrop({required TreeNode target}) {
    return target is CompositeTreeNode;
  }

  @override
  bool canBeSelected({bool isDraggingModeActive = false}) {
    return !isDraggingModeActive;
  }

  @override
  String toString() {
    return 'LeafTreeNode(Node: $node, parent: $nodeParent)';
  }
}
