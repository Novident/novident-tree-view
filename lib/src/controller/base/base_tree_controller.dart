import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tree_view/src/interfaces/tree_common_ops.dart';
import 'package:meta/meta.dart';

import '../../entities/enums/log_level.dart';
import '../../entities/enums/log_state.dart';
import '../../entities/enums/search_order.dart';
import '../../entities/node/node.dart';
import '../../entities/selection/node_selection.dart';
import '../../entities/tree/tree_changes.dart';
import '../../entities/tree/tree_operation.dart';
import '../../entities/tree/tree_state.dart';
import '../../entities/tree_node/composite_tree_node.dart';
import '../../entities/tree_node/selectable_tree_node.dart';
import '../../entities/tree_node/tree_node.dart';
import '../../exceptions/invalid_custom_node_builder_callback_return.dart';
import '../../exceptions/invalid_node_id.dart';
import '../../exceptions/invalid_node_update.dart';
import '../../exceptions/invalid_type_ref.dart';
import '../../exceptions/node_not_exist_in_tree.dart';
import '../../interfaces/base_logger.dart';
import '../../logger/tree_logger.dart';
import '../../utils/search_tree_node_child.dart';

abstract class BaseTreeController extends ChangeNotifier implements TreeOperations {
  @protected
  _Root root = _Root(
    node: Node.withId(-1),
    children: List.from([]),
    nodeParent: 'no-parent-2023',
    isExpanded: false,
  );

  @protected
  bool disposed = false;
  // Tells to the Tree if should listen the keyboard events
  //
  // If the tree is focused, we listen the events like arrow up or down
  // or copy and paste to the nodes
  //
  // If the tree is not focused the events will be ignored
  @protected
  bool focused = false;
  @protected
  TreeNode? currentSelectedNode;
  BaseLogger logger = TreeLogger(state: LogState.debug);
  @protected
  final NodeSelection selection = NodeSelection(selection: []);

  Stream<TreeStateChanges> get changes => root.changes;

  @experimental
  set registerLogger(BaseLogger newLogger) {
    logger = newLogger;
    notifyListeners();
  }

  set focus(bool setFocus) {
    if (setFocus == focused) return;
    focused = setFocus;
    notifyListeners();
  }

  void setNewIdToRoot(String id) {
    verifyState();
    assert(id.isNotEmpty, 'The id passed cannot be empty');
    assert(id.replaceAll(RegExp(r'\p{Z}', unicode: true), '').isNotEmpty, 'The id passed cannot be empty');
    final lastNodeState = root.node;
    final newRootState = root.clone();
    newRootState.updateInternalNodesByParentId(id);
    root.addNewChange([...newRootState.children], TreeOperation.update, lastNodeState);
    root = root.copyWith(
      node: root.node.copyWith(
        id: id,
      ),
    );
    root.updateInternalNodesByParentId(id);
    notifyListeners();
  }

  bool get isFocused => focused;

  /// Get all nodes contained into the [Root]
  /// of the tree
  List<TreeNode> get tree {
    verifyState();
    return [...root.children];
  }

  set tree(List<TreeNode> newRoot) {
    verifyState();
    root.addNewChange([...newRoot], TreeOperation.replace);
    root = root.copyWith(
      children: [...newRoot],
    );
    logger.writeLog(
      level: LogLevel.info,
      message: 'Root of the project was re-setted. [Root => ${root.length}]',
    );
    notifyListeners();
  }

  String get treeId {
    verifyState();
    return root.id;
  }

  TreeNode? get visualSelection => currentSelectedNode;

  @override
  TreeNode? backChild(Node node, [int? indexNode]) {
    verifyState();
    final isRootLevel = node.level == -1 && node.id == root.node.id;
    if (isRootLevel && indexNode != null) {
      if (indexNode == 0) return null;
      return root.elementAt(indexNode - 1);
    } else {
      for (int i = 0; i < root.length; i++) {
        final treeNode = root.elementAt(i);
        if (treeNode.node.id == node.id) {
          if (i == 0) return null;
          return root.elementAt(i - 1);
        } else if (treeNode is CompositeTreeNode && treeNode.isNotEmpty) {
          final backNode = treeNode.backChild(node, true, indexNode);
          if (backNode != null) return backNode;
        }
      }
    }
    return null;
  }

  @override
  void clearChildrenByNode(String nodeId) {
    verifyState();
    for (int index = 0; index < root.length; index++) {
      final node = root.elementAt(index);
      if (node is CompositeTreeNode && node.node.id == nodeId) {
        logger.writeLog(
          level: LogLevel.info,
          message: 'Node ${node.id} was cleared. [Node(Level: ${node.level}) => ${node.length}]',
        );
        root.addNewChange(
          [node.copyWith(children: [])],
          TreeOperation.clearComposite,
          null,
          root,
        );
        root[index] = node.copyWith(children: []);
        break;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final shouldBreak = _clearChildrenHelper(nodeId, node);
        if (shouldBreak) break;
      }
    }
    notifyListeners();
  }

  // state methods

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    root.dispose();
    logger.dispose();
    disposed = true;
  }

  bool existInRoot(String nodeId) {
    for (int i = 0; i < root.length; i++) {
      final node = root.elementAt(i);
      if (node.node.id == nodeId) {
        return true;
      }
    }
    return false;
  }

  bool existNode(String nodeId) {
    for (int i = 0; i < root.length; i++) {
      final node = root.elementAt(i);
      if (node.node.id == nodeId) {
        return true;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final foundedNode = node.existNode(nodeId);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  @override
  int getAllAvailableNodesInCompositeNode(String nodeId, {bool recursive = false}) {
    if (!existNode(nodeId)) {
      throw NodeNotExistInTree(
        message:
            'The node $nodeId not exist into the tree currently. Please, ensure first if the node was removed before insert any node',
        node: nodeId,
      );
    }
    final node = getNodeById(nodeId) as CompositeTreeNode;
    int nodesCount = node.length;

    void recursiveNodeSearch(CompositeTreeNode composite) {
      for (var subNode in composite.children) {
        nodesCount++;
        if (subNode is CompositeTreeNode && subNode.isNotEmpty) {
          recursiveNodeSearch(subNode);
        }
      }
    }

    if (recursive) recursiveNodeSearch(node);

    return nodesCount;
  }

  @override
  List<TreeNode>? getAllNodeMatches(bool Function(TreeNode node) predicate) {
    final Set<TreeNode> matchedNodes = {};

    void matchNode(List<TreeNode> children) {
      for (var node in children) {
        if (predicate(node)) {
          matchedNodes.add(node);
        } else if (node is CompositeTreeNode && node.isNotEmpty) {
          matchNode(node.children);
        }
      }
    }

    matchNode(root.children);

    return matchedNodes.toList();
  }

  @override
  TreeNode? getNodeWhere(bool Function(TreeNode node) predicate) {
    TreeNode? foundedNode;

    bool searchNodeWhere(List<TreeNode> children) {
      for (var node in children) {
        if (predicate(node)) {
          foundedNode = node;
          return true;
        } else if (node is CompositeTreeNode && node.isNotEmpty) {
          final wasFounded = searchNodeWhere(node.children);
          if (wasFounded) return true;
        }
      }
      return false;
    }

    searchNodeWhere(root.children);

    return foundedNode;
  }

  @override
  List<TreeNode>? getAllNodes() {
    verifyState();
    return [...root.children];
  }

  @override
  List<TreeNode>? getAllNodesInComposite(String nodeId) {
    verifyState();
    CompositeTreeNode? node;
    for (var treenode in root.children) {
      if (treenode is CompositeTreeNode && treenode.node.id == nodeId) {
        node = treenode;
      } else if (treenode is CompositeTreeNode && treenode.isNotEmpty) {
        node = getCompositeNode(nodeId, compositeNode: treenode);
      }
    }
    if (node != null) return [...node.children];
    throw InvalidNodeId(
      message:
          'The gived node: $nodeId is not founded on any part of the tree. Please, ensure the node really exist into the Tree',
    );
  }

  @override
  List<SelectableTreeNode>? getAllNodesInSelection(String nodeId) {
    verifyState();
    if (selection.isEmpty) return null;
    return [...selection.selection];
  }

  @override
  CompositeTreeNode<TreeNode>? getCompositeNode(String nodeId, {CompositeTreeNode<TreeNode>? compositeNode}) {
    verifyState();
    if (compositeNode != null) {
      for (var treenode in compositeNode.children) {
        if (treenode is CompositeTreeNode && treenode.node.id == nodeId) {
          return treenode;
        } else if (treenode is CompositeTreeNode) {
          final composite = getCompositeNode(nodeId, compositeNode: treenode);
          if (composite != null) return composite;
        }
      }
    } else {
      for (var treenode in root.children) {
        if (treenode is CompositeTreeNode && treenode.node.id == nodeId) {
          return treenode;
        } else if (treenode is CompositeTreeNode && treenode.isNotEmpty) {
          final composite = getCompositeNode(nodeId, compositeNode: treenode);
          if (composite != null) return composite;
        }
      }
    }
    return null;
  }

  @override
  TreeNode? getNodeById(String nodeId) {
    verifyState();
    for (var node in root.children) {
      if (node.node.id == nodeId) {
        return node;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final targetNode = searchChild(node, Node.base(nodeId), SearchStrategy.target);
        if (targetNode != null) return targetNode;
      }
    }
    logger.writeLog(
      level: LogLevel.info,
      message: 'Was not founded Node(id: $nodeId) or not exist in the current state of the tree',
    );
    throw InvalidNodeId(message: 'The id: $nodeId is not valid or not exist currently into the tree');
  }

  @protected
  bool insertAboveNodeInSubComposite(CompositeTreeNode composite, TreeNode node, String target) {
    for (int i = 0; i < composite.length; i++) {
      final belowNode = composite.elementAt(i);
      if (belowNode.node.id == target) {
        if (node is CompositeTreeNode) {
          node.formatChildLevels();
        }
        root.addNewChange([node], TreeOperation.insertAbove, null, composite);
        composite.insert(
            i, node.copyWith(nodeParent: composite.id, node: node.node.copyWith(level: belowNode.level)));
        return true;
      } else if (belowNode is CompositeTreeNode && belowNode.isNotEmpty) {
        final inserted = insertAboveNodeInSubComposite(belowNode, node, target);
        if (inserted) return true;
      }
    }
    return false;
  }

  @override
  void insertAboveWithCallback(TreeNode Function() callback, String childBelowId, {bool removeIfNeeded = false}) {
    if (!existNode(childBelowId)) {
      throw NodeNotExistInTree(
        message:
            'The node $childBelowId not exist into the tree currently. Please, ensure first if the node was removed before insert any node',
        node: childBelowId,
      );
    }
    final node = callback();
    if (removeIfNeeded) {
      // removes the node from the tree
      // insert the node at the position
      removeWhere((element) => element.node.id == node.node.id, verifyDuplicates: true);
    }
    for (int i = 0; i < root.length; i++) {
      final belowNode = root.elementAt(i);
      if (belowNode.node.id == childBelowId) {
        final beforeIndex = (i - 1) == -1 ? 0 : i;
        if (node is CompositeTreeNode) {
          node.formatChildLevels();
        }
        root.addNewChange([node], TreeOperation.insertAbove, null, root);
        root.insert(beforeIndex, node.copyWith(nodeParent: root.id, node: node.node.copyWith(level: 0)));
        break;
      } else if (belowNode is CompositeTreeNode && belowNode.isNotEmpty) {
        final inserted = insertAboveNodeInSubComposite(belowNode, node, childBelowId);
        if (inserted) break;
      }
    }
    notifyListeners();
  }

  @override
  void insertAllAbove(List<TreeNode> nodes, String childBelowId,
      {bool removeIfNeeded = false, bool verifyDuplicates = false}) {
    for (var node in nodes) {
      // removes if is necessary
      removeWhere((element) => element.node.id == node.node.id, verifyDuplicates: verifyDuplicates);
      insertAbove(node, childBelowId);
    }
    notifyListeners();
  }

  @override
  void insertAllAt(
    List<TreeNode> nodes,
    String nodeTargetId, {
    bool removeIfNeeded = false,
    bool verifyDuplicates = false,
  }) {
    for (var node in nodes) {
      // removes if is necessary
      removeWhere((element) => element.node.id == node.node.id, verifyDuplicates: verifyDuplicates);
      insertAt(node, nodeTargetId);
    }
    notifyListeners();
  }

  // helper functions

  @protected
  bool insertAtInSubCompositeWithCallback(
    CompositeTreeNode compositeNode,
    TreeNode Function() callback,
    String parentId,
  ) {
    final node = callback();
    for (int i = 0; i < compositeNode.length; i++) {
      final treeNode = compositeNode.elementAt(i);
      if (treeNode is CompositeTreeNode) {
        if (treeNode.id == parentId) {
          if (node is CompositeTreeNode) {
            node.formatChildLevels();
          }
          root.addNewChange(
            [node],
            TreeOperation.insert,
            null,
            treeNode,
          );
          treeNode
              .add(node.copyWith(node: node.node.copyWith(level: treeNode.level + 1), nodeParent: treeNode.id));
          return true;
        } else if (treeNode.isNotEmpty) {
          final inserted = insertAtInSubCompositeWithCallback(treeNode, callback, parentId);
          if (inserted) {
            compositeNode[i] = treeNode.copyWith(isExpanded: true);
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  void insertAtWithCallback(String? parentId, TreeNode Function() callback, {bool removeIfNeeded = false}) {
    bool insertInRoot = parentId == null || parentId == treeId;
    final node = callback();
    if (removeIfNeeded) {
      removeWhere((element) => element.id == node.id, verifyDuplicates: true);
    }
    if (insertInRoot) {
      root.add(node.copyWith(node: node.node.copyWith(level: 0), nodeParent: root.id));
      notifyListeners();
      return;
    }
    for (int i = 0; i < root.length; i++) {
      final treeNode = root.elementAt(i);
      if (treeNode is CompositeTreeNode) {
        if (treeNode.id == parentId) {
          if (node is CompositeTreeNode) {
            node.formatChildLevels();
          }
          root.addNewChange(
            [node],
            TreeOperation.insert,
            null,
            treeNode,
          );
          treeNode
              .add(node.copyWith(node: node.node.copyWith(level: treeNode.level + 1), nodeParent: treeNode.id));
        } else if (treeNode.isNotEmpty) {
          final inserted = insertAtInSubCompositeWithCallback(treeNode, callback, parentId);
          if (inserted) {
            root[i] = treeNode.copyWith(isExpanded: true);
            break;
          }
        }
      }
    }
    notifyListeners();
  }

  @protected
  bool insertNodeInSubComposite(CompositeTreeNode composite, TreeNode node, String target) {
    for (int i = 0; i < composite.length; i++) {
      final compositeNode = composite.elementAt(i);
      if (compositeNode.node.id == target) {
        // when the user will insert a node the target need to be a compositeTreeNode
        if (compositeNode is! CompositeTreeNode) {
          throw InvalidTypeRef(
            message:
                'The node [${compositeNode.runtimeType}-$target] is not a valid target to insert the ${node.runtimeType} into it. Please, ensure of the target node is a CompositeTreeNode to allow insert nodes into itself correctly',
            data: compositeNode,
            time: DateTime.now(),
            targetFail: target,
          );
        }
        if (!composite.existInRoot(node.node.id)) {
          logger.writeLog(
            level: LogLevel.fine,
            message:
                'Inserted ${node.runtimeType}(id: ${node.id}) node in ${composite.runtimeType}(id: ${composite.id}). [${composite.runtimeType} change => ${composite.level}]',
          );
          if (node is CompositeTreeNode) {
            node.formatChildLevels();
          }
          root.addNewChange(
              [node.copyWith(nodeParent: compositeNode.id)], TreeOperation.insert, null, compositeNode);
          compositeNode.add(node.copyWith(
              nodeParent: compositeNode.id, node: node.node.copyWith(level: compositeNode.level + 1)));
          composite[i] = compositeNode.copyWith(isExpanded: true);
          return true;
        } else {
          return true;
        }
      } else if (compositeNode is CompositeTreeNode && compositeNode.isNotEmpty) {
        final inserted = insertNodeInSubComposite(compositeNode, node, target);
        if (inserted) {
          composite[i] = compositeNode.copyWith(isExpanded: true);
          return true;
        }
      }
    }
    return false;
  }

  @override
  TreeNode? nextChild(Node node, [int? indexNode]) {
    verifyState();
    final isRootLevel = node.level == -1 && node.id == root.node.id;
    if (isRootLevel && indexNode != null) {
      if (indexNode + 1 >= root.length) return null;
      return root.elementAt(indexNode + 1);
    } else {
      for (int i = 0; i < root.length; i++) {
        final treeNode = root.elementAt(i);
        if (treeNode.node.id == node.id) {
          if (i + 1 >= root.length) return null;
          return root.elementAt(i + 1);
        } else if (treeNode is CompositeTreeNode && treeNode.isNotEmpty) {
          final nextNode = treeNode.nextChild(node, true, indexNode);
          if (nextNode != null) return nextNode;
        }
      }
    }
    return null;
  }

  /// If the user press outside of the tree
  /// the visual selection will be cleared
  void onTapOutsideRemoveVisualSelection() {
    verifyState();
    currentSelectedNode = null;
    focused = false;
    notifyListeners();
  }

  @override
  void removeAllInSelection() {
    for (int i = 0; i < selection.length; i++) {
      final node = selection.elementAt(i);
      if (existInRoot(node.node.id)) {
        root.addNewChange(
          [node],
          TreeOperation.delete,
        );
        root.remove(node);
      } else if (existNode(node.node.id)) {
        removeWhere((element) => element.node.id == node.node.id, ignoreRoot: true);
      }
    }
    selection.clear();
    notifyListeners();
  }

  // when return true the parent need override the root parent of this composite
  @protected
  bool removeChild(
    CompositeTreeNode compositeNode,
    Node? target, [
    bool Function(TreeNode)? predicate,
    bool verifyDuplicates = false,
  ]) {
    for (int i = 0; i < compositeNode.length; i++) {
      final node = compositeNode.elementAt(i);
      if (node.node.id == target?.id || predicate?.call(node) == true) {
        root.addNewChange([node], TreeOperation.delete, null, compositeNode);
        compositeNode.remove(node);
        if (!verifyDuplicates) return true;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final foundedNode = removeChild(node, target, predicate, verifyDuplicates);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  // if the selection is active and the user removes some of these
  // node selected this will be called
  @override
  SelectableTreeNode? removeFromSelection(String nodeId) {
    if (selection.checkExistence(nodeId)) {
      final node = removeWhere((element) => element.node.id == nodeId) as SelectableTreeNode?;
      if (node == null) {
        throw InvalidNodeId(message: 'The node: $nodeId is invalid or not exist into the tree');
      }
      selection.removeWhere((element) => element.node.id == nodeId);
      notifyListeners();
      return node;
    }
    return null;
  }

  @override
  void removeNodeInSelection(String nodeId) {
    if (selection.checkExistence(nodeId)) {
      selection.removeWhere((element) => element.node.id == nodeId);
      notifyListeners();
      return;
    }
    throw InvalidNodeId(message: 'The node: $nodeId is invalid or not exist into the tree');
  }

  @override
  TreeNode? removeWhere(
    bool Function(TreeNode node) predicate, {
    bool ignoreRoot = false,
    bool verifyDuplicates = false,
  }) {
    for (int i = 0; i < root.length; i++) {
      final node = root.elementAt(i);
      if (predicate(node) && !ignoreRoot) {
        root.addNewChange(
          [node],
          TreeOperation.delete,
        );
        root.remove(node);
        notifyListeners();
        if (!verifyDuplicates) return node;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final isFounded = removeChild(node, null, predicate, verifyDuplicates);
        if (isFounded) {
          root[i] = node;
          notifyListeners();
          return node;
        }
      }
    }
    return null;
  }

  @experimental
  void setToDefaultLogger({LogState? logState, TreeLogger? defaultLogger}) {
    logger = defaultLogger ?? TreeLogger(state: logState ?? LogState.noState);
    notifyListeners();
  }

  /// setVisualSelection just makes of the tree directory
  /// select a node
  ///
  /// It's not the same type of NodeSelection
  /// because this just make possible press a node
  /// and set this one to the state of the controller
  void setVisualSelection(TreeNode? node) {
    verifyState();
    if (node == null) return;
    if (currentSelectedNode?.node.id == node.node.id) return;
    currentSelectedNode = node;
    focused = true;
    notifyListeners();
  }

  @override
  bool updateInSelectionNodeAt(SelectableTreeNode node) {
    if (selection.checkExistence(node.node.id)) {
      final indexOf = selection.indexWhere((element) => element.node.id == node.node.id);
      if (indexOf == -1) return false;
      selection[indexOf] = node;
      notifyListeners();
    }
    return false;
  }

  @override
  bool updateNodeAtWithCallback(String nodeId, TreeNode Function(TreeNode) callback) {
    for (int i = 0; i < root.length; i++) {
      final node = root.elementAt(i);
      if (node.id == nodeId) {
        final newChildState = callback(node);
        // verify if the callback created by the dev
        // does not change the node value of the tree node
        if (newChildState.node != node.node || newChildState.id != node.id) {
          throw InvalidCustomNodeBuilderCallbackReturn(
              message:
                  'Invalid custom node builded $newChildState. Please, ensure of create a TreeNode valid with the same Node of the passed as the argument',
              originalVersionNode: node,
              newNodeVersion: newChildState,
              reason: 'The Node of the TreeNode cannot be different than the original');
        }
        root.addNewChange(
          [newChildState],
          TreeOperation.update,
          null,
          node,
        );
        root[i] = newChildState;
        notifyListeners();
        return true;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final wasUpdated = updateSubNodesWithCallback(node.children, callback, nodeId);
        if (wasUpdated) {
          root[i] = node;
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  @protected
  bool updateSubNodes(List<TreeNode> children, TreeNode targetNode, String nodeId) {
    bool updated = false;
    List<String> visited = <String>[];
    int i = 0;
    while (i < children.length) {
      final TreeNode child = children[i];
      if (child is CompositeTreeNode) {
        if (!visited.contains(child.id)) {
          visited.add(child.id);
          if (child.id == nodeId) {
            int index = children.indexWhere((element) => element.id == nodeId);
            if (targetNode.node != child.node || targetNode.id != child.id) {
              throw InvalidNodeUpdate(
                  message:
                      'Invalid custom node builded $targetNode. Please, ensure of create a TreeNode valid with the same Node of the passed as the argument',
                  originalVersionNode: child,
                  newNodeVersion: targetNode,
                  reason: 'The Node of the TreeNode cannot be different than the original');
            }
            root.addNewChange(
              [targetNode],
              TreeOperation.update,
              null,
              child,
            );
            children[index] = targetNode;
            updated = true;
            return updated;
          } else {
            updated = updateSubNodes(child.children, targetNode, nodeId);
            if (updated) {
              break;
            }
          }
        }
      }
      i++;
    }
    return updated;
  }

  @protected
  bool updateSubNodesWithCallback(
    List<TreeNode> children,
    TreeNode Function(TreeNode) callback,
    String nodeId,
  ) {
    bool updated = false;
    int i = 0;
    while (i < children.length) {
      final TreeNode child = children.elementAt(i);
      if (child.id == nodeId) {
        int index = children.indexWhere((element) => element.id == nodeId);
        final newChildState = callback(child);
        // verify if the callback created by the dev
        // does not change the node value of the tree node
        if (newChildState.node != child.node || newChildState.id != child.id) {
          throw InvalidCustomNodeBuilderCallbackReturn(
              message:
                  'Invalid custom node builded $newChildState. Please, ensure of create a TreeNode valid with the same Node of the passed as the argument',
              originalVersionNode: child,
              newNodeVersion: newChildState,
              reason: 'The Node of the TreeNode cannot be different than the original');
        }
        root.addNewChange(
          [newChildState],
          TreeOperation.update,
          null,
          child,
        );
        children[index] = newChildState;
        updated = true;
        return updated;
      } else if (child is CompositeTreeNode && child.isNotEmpty) {
        updated = updateSubNodesWithCallback(child.children, callback, nodeId);
        if (updated) {
          break;
        }
      }
      i++;
    }
    return updated;
  }

  @protected
  void verifyState() {
    assert(!disposed, 'This TreeController is no longer usable because it is already disposed');
    logger.verifyState();
  }

  bool _clearChildrenHelper(String nodeId, CompositeTreeNode node) {
    for (int index = 0; index < node.length; index++) {
      final treenode = node.elementAt(index);
      if (treenode is CompositeTreeNode && treenode.node.id == nodeId) {
        root.addNewChange(
          [treenode],
          TreeOperation.clearComposite,
          null,
          node,
        );
        node[index] = treenode.copyWith(children: []);
        return true;
      } else if (treenode is CompositeTreeNode && treenode.isNotEmpty) {
        final shouldBreak = _clearChildrenHelper(nodeId, treenode);
        if (shouldBreak) return shouldBreak;
      }
    }
    return false;
  }
}

/// Represents the root of the directory view
class _Root extends CompositeTreeNode<TreeNode> {
  final StreamController<TreeStateChanges> _rootState = StreamController.broadcast();

  _Root({
    required super.node,
    required super.children,
    required super.nodeParent,
    required super.isExpanded,
  });

  /// By now we just use a [simple list] in future release we **could replace** this
  /// by a more complex stack with the states of the tree before and after, like **undo** and **redo**
  /// **features** from any [text editor]
  Stream<TreeStateChanges> get changes => _rootState.stream;

  @override
  List<Object?> get props => [node, children, isExpanded, nodeParent];

  void addNewChange(List<TreeNode> nodes, TreeOperation op, [Node? oldNodeState, TreeNode? changedNode]) {
    final oldState = TreeState(node: oldNodeState ?? node, children: children);
    final change = TreeChange(children: nodes, operation: op, node: changedNode);
    final TreeStateChanges changes = TreeStateChanges(
      oldState: oldState,
      change: change,
    );
    _rootState.add(changes);
  }

  @override
  bool canBePressed() => false;

  @override
  bool canBeSelected({bool isDraggingModeActive = false}) => false;

  @override
  bool canDrag({bool isSelectingModeActive = false}) => false;

  @override
  bool canDrop({TreeNode? target}) => true;

  @override
  CompositeTreeNode<TreeNode> clone() {
    return _Root(
      node: node,
      children: children,
      nodeParent: nodeParent,
      isExpanded: isExpanded,
    );
  }

  @override
  _Root copyWith({Node? node, List<TreeNode>? children, bool? isExpanded, String? nodeParent}) {
    return _Root(
      node: node ?? this.node,
      children: children ?? this.children,
      nodeParent: nodeParent ?? this.nodeParent,
      isExpanded: false,
    );
  }

  void dispose() {
    _rootState.close();
    clear();
  }
}
