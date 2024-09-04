import 'tree_node.dart';
import '../../interfaces/selectable_node_mixin.dart';

/// A representation of a TreeNode that can be selected by common press
/// operations
///
/// If you want to avoid any press call you just use [CompositeTreeNode] or [LeafTreeNode]
/// to avoid this behavior
///
/// or
///
/// Just override the [canBePressed] and [canBeSelected]
/// functions to return always false
abstract class SelectableTreeNode extends TreeNode implements Selectable {
  SelectableTreeNode({
    required super.node,
    required super.nodeParent,
  });
}
