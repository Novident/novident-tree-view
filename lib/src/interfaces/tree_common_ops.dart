import '../entities/node/node.dart';
import '../entities/tree_node/composite_tree_node.dart';
import '../entities/tree_node/selectable_tree_node.dart';
import '../entities/tree_node/tree_node.dart';

/// Represents all the common operations used by
/// the tree directory
mixin TreeOperations {
  /// This insert the node at the target specified
  void insertAt(TreeNode node, String parentId, {bool removeIfNeeded = false});

  /// Insert a node in the tree but with a custom builder
  void insertAtWithCallback(String? parentId, TreeNode Function() callback,
      {bool removeIfNeeded = false});

  /// This insert the node at the root level of the tree
  void insertAtRoot(TreeNode node, {bool removeIfNeeded = false});

  /// This insert all the nodes (usually just used when selection is active) into the target specified
  void insertAllAt(List<TreeNode> nodes, String parentId,
      {bool removeIfNeeded = false});

  /// This insert the node above of its target
  void insertAbove(TreeNode node, String childBelowId,
      {bool removeIfNeeded = false});

  /// Insert a node in the tree but with a custom builder
  void insertAboveWithCallback(
      TreeNode Function() callback, String childBelowId,
      {bool removeIfNeeded = false});

  /// This insert all the nodes (usually just used when selection is active) above its target
  void insertAllAbove(List<TreeNode> nodes, String childBelowI,
      {bool removeIfNeeded = false});

  /// Get the node by the id
  /// this will
  TreeNode? getNodeById(String nodeId);

  /// Get the node by the id
  TreeNode? getNodeWhere(bool Function(TreeNode node) predicate);

  /// Get all the nodes into the root
  /// tree
  List<TreeNode>? getAllNodes();

  /// Get all the nodes that matches with the predicate
  List<TreeNode>? getAllNodeMatches(bool Function(TreeNode node) predicate);

  /// Get all the nodes into a [CompositeTreeNode]
  /// if the node id passed is not from a [CompositeTreeNode]
  /// then will throw an InvalidNodeId exception
  List<TreeNode>? getAllNodesInComposite(String nodeId);

  /// Get a [CompositeTreeNode] given a node target id
  CompositeTreeNode? getCompositeNode(String nodeId);

  /// Get all the nodes into the NodeSelection
  /// will throw null if the NodeSelection is empty
  List<SelectableTreeNode>? getAllNodesInSelection(String nodeId);

  /// Search the next node given a node id
  TreeNode? nextChild(Node node);

  /// Search the before node given a node id
  TreeNode? backChild(Node node);

  /// Removes the node given a node target id
  TreeNode? removeAt(String nodeId, {bool ignoreRoot = false});

  /// If the user remove a node while him while a selection is active
  /// then this will be called (this just remove the node selected from the NodeSelection)
  void removeNodeInSelection(String nodeId);

  /// If the user remove a node while him while a selection is active
  /// then this will be called. Removes the node also in the tree
  SelectableTreeNode? removeFromSelection(String nodeId);

  /// This removes the node from the tree if predicate its satisfied
  TreeNode? removeWhere(bool Function(TreeNode node) predicate,
      {bool ignoreRoot = false});

  /// Update a node in the tree
  bool updateNodeAt(TreeNode node, String nodeId);

  /// Update a node in the tree
  bool updateNodeAtWithCallback(
      String nodeId, TreeNode Function(TreeNode) callback);

  /// Open all CompositeTreeNode until found the node
  ///
  /// If the targetNode is a CompositeTreeNode and you want to append it too,
  /// set [openTargetIfNeeded] to true
  bool openUntilNode(TreeNode targetNode, {bool openTargetIfNeeded = false});

  /// Update a node in the selection if this is active
  bool updateInSelectionNodeAt(SelectableTreeNode node);

  /// This will remove all the nodes in selection from the tree
  void removeAllInSelection();

  /// Get the number of the nodes available into the CompositeTreeNode
  ///
  /// [recursive] means if the search must contains also the nodes
  /// into a CompositeTreeNode child from the the target passed
  int getAllAvailableNodesInCompositeNode(String nodeId,
      {bool recursive = false});

  /// Clear all the nodes into a CompositeTreeNode
  /// if the CompositeTreeNode is not founded
  /// will throw an InvalidNodeId exception
  void clearChildrenByNode(String nodeId);

  /// Clear all tree and the any selection if needed
  void clearRoot();
}
