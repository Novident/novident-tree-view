import 'package:flutter/material.dart';
import '../../../entities/node/node.dart';
import '../../../entities/tree_node/tree_node.dart';

@immutable
class TreeActions {
  // By now these actions are not longer used
  // probably them will be needed in the TreeToolbar
  // implementation to add this common actions there
  //
  // Them has not any effect on common operations into the tree
  // if you want to make this, you will need to define [NodeDragGestures]
  // in [TreeConfiguration] class
  final void Function(Node nodeRemoved)? customRemoveItem;
  final TreeNode Function(TreeNode node, String target)? customAddItem;
  final TreeNode Function(TreeNode node, String target)? customInsertAtItem;

  /// Customize the insertion above a node
  ///
  /// nodeBelowId references to the node that will be moved down by the new node
  /// when it be inserted above that node
  final void Function(TreeNode node, String nodeBelowId)? customInsertAboveNode;

  /// This allow us customize how is updated the nodes by our own implementation
  /// giving the ability to update by a new way any node
  final TreeNode Function(TreeNode newNodeState)? customUpdateNodeUpdate;

  /// Just is called is the selection is turned off
  /// and the user start manually it
  final void Function(TreeNode)? onStartSelection;

  /// just is called is selection mode is active
  final void Function(TreeNode)? onSelectAnotherNode;
  final TreeNode Function()? onTapItemWhileSelectionIsActive;

  const TreeActions({
    this.customRemoveItem,
    this.customAddItem,
    this.customInsertAtItem,
    this.customInsertAboveNode,
    this.customUpdateNodeUpdate,
    this.onStartSelection,
    this.onSelectAnotherNode,
    this.onTapItemWhileSelectionIsActive,
  });
}
