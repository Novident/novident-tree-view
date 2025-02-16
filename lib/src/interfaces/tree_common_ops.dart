import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/entities/node/node_details.dart';

import '../entities/node/node.dart';

/// Represents all the common operations used by
/// the tree directory
mixin TreeOperations {
  /// This insert the node at the target specified
  void insertAt(Node node, String parentId, {bool removeIfNeeded = false});

  /// Insert a node in the tree but with a custom builder
  void insertAtWithCallback(String? parentId, Node Function() callback,
      {bool removeIfNeeded = false});

  /// This insert the node at the root level of the tree
  void insertAtRoot(Node node, {bool removeIfNeeded = false});

  /// This insert all the nodes (usually just used when selection is active) into the target specified
  void insertAllAt(List<Node> nodes, String parentId,
      {bool removeIfNeeded = false});

  /// This insert the node above of its target
  void insertAbove(Node node, String childBelowId,
      {bool removeIfNeeded = false});

  /// Insert a node in the tree but with a custom builder
  void insertAboveWithCallback(Node Function() callback, String childBelowId,
      {bool removeIfNeeded = false});

  /// This insert all the nodes (usually just used when selection is active) above its target
  void insertAllAbove(List<Node> nodes, String childBelowI,
      {bool removeIfNeeded = false});

  /// Get the node by the id
  /// this will
  Node? getNodeById(String nodeId);

  /// Get the node by the id
  Node? getNodeWhere(bool Function(Node node) predicate);

  /// Get all the nodes that matches with the predicate
  List<Node>? getAllNodeMatches(bool Function(Node node) predicate);

  /// Get all the nodes into a [NodeContainer]
  ///
  /// if the node id passed is not from a [NodeContainer]
  /// then will throw an InvalidNodeId exception
  List<Node>? getAllChildrenInNode(String nodeId);

  /// Search the next node given a node id
  Node? childAfterThis(NodeDetails node);

  /// Search the before node given a node id
  Node? childBeforeThis(NodeDetails node);

  /// Removes the node given a node target id
  Node? removeAt(String nodeId, {bool ignoreRoot = false});

  /// This removes the node from the tree if predicate its satisfied
  Node? removeWhere(bool Function(Node node) predicate,
      {bool ignoreRoot = false});

  /// Update a node in the tree
  bool updateNodeAt(Node node, String nodeId);

  /// Update a node in the tree
  bool updateNodeAtWithCallback(String nodeId, Node Function(Node) callback);

  /// Open all NodeContainer until found the node
  ///
  /// If the targetNode is a NodeContainer and you want to append it too,
  /// set [openTargetIfNeeded] to true
  bool expandAllUntilTarget(Node targetNode, {bool openTargetIfNeeded = false});

  /// Get the number of the nodes available into a NodeContainer
  ///
  /// [recursive] means if the search must contains also the nodes
  /// into a NodeContainer child from the the target passed
  int getFullCountOfChildrenInNode(NodeContainer? node, String? nodeId,
      {bool recursive = false});

  /// Clear all the nodes into aMultiNode
  /// if the NodeContainer is not founded
  /// will throw an InvalidNodeId exception
  void clearNodeChildren(String nodeId);

  /// Clear all tree and the any selection if needed
  void clearTree();
}
