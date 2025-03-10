import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tree_view/src/entities/node/node_details.dart';
import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';
import 'package:flutter_tree_view/src/extensions/base_controller_helpers.dart';
import 'package:flutter_tree_view/src/interfaces/tree_common_ops.dart';
import 'package:meta/meta.dart';
import '../../entities/enums/search_order.dart';
import '../../entities/node/node.dart';
import '../../entities/tree/tree_changes.dart';
import '../../entities/tree/tree_operation.dart';
import '../../entities/tree_node/root_node.dart';
import '../../exceptions/invalid_custom_node_builder_callback_return.dart';
import '../../exceptions/invalid_node_id.dart';
import '../../exceptions/node_not_exist_in_tree.dart';
import '../../logger/tree_logger.dart';
import '../../utils/search_tree_node_child.dart';

abstract class BaseTreeController extends ChangeNotifier
    implements TreeOperations {
  final Root root = Root(
    details: NodeDetails(level: -1, id: 'root', owner: null),
    children: List.from([]),
    isExpanded: false,
  );

  bool get isEmpty => root.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => root.length;

  bool _disposed = false;

  bool get disposed => _disposed;

  @protected
  @internal
  ValueNotifier<Node?> currentSelectedNode = ValueNotifier(null);

  ValueNotifier<Node?> get selection => currentSelectedNode;

  Stream<TreeStateChanges> get changes => root.changes;

  /// Configures log output parameters,
  /// such as log level and log output callbacks,
  /// with this variable.
  TreeLoggerConfiguration get logConfiguration => TreeLoggerConfiguration();

  void setHandlerToLogger(
      {required void Function(String)? callback, TreeLogLevel? logLevel}) {
    logConfiguration
      ..handler = callback
      ..level = logLevel ?? TreeLogLevel.all;
  }

  /// Get all nodes contained into the [Root]
  /// of the tree
  List<Node> get children {
    verifyState();
    return [...root.children];
  }

  set children(List<Node> newRoot) {
    verifyState();
    root.addNewChange([...newRoot], TreeOperation.replace_all_tree_children);
    root.clearAndOverrideState(newRoot);
    // reload the visual selection since the new root couldn't contain
    // the current node in selection
    selectNode(null);
    TreeLogger.root.debug(
      'Root was cleared and it has new children state',
    );
  }

  String get id {
    verifyState();
    return root.id;
  }

  Node? get selectedNode => currentSelectedNode.value;

  @override
  Node? childBeforeThis(NodeDetails node, [int? indexNode]) {
    verifyState();
    final isRootLevel = node.id == root.details.id;
    if (isRootLevel && indexNode != null) {
      if (indexNode == 0) return root.elementAt(0);
      return root.elementAt(indexNode - 1);
    } else {
      for (int i = 0; i < root.length; i++) {
        final treeNode = root.elementAt(i);
        if (treeNode.details.id == node.id) {
          if (i == 0) return treeNode;
          return root.elementAt(i - 1);
        } else if (treeNode is NodeContainer && treeNode.isNotEmpty) {
          final backNode = treeNode.childBeforeThis(node, true, indexNode);
          if (backNode != null) return backNode;
        }
      }
    }
    return null;
  }

  /// Use this with caution because this method
  /// does not check if the current selection
  /// is a node into the node that will be cleared
  @override
  void clearNodeChildren(String nodeId) {
    verifyState();
    for (int index = 0; index < root.length; index++) {
      final node = root.elementAt(index);
      if (node is NodeContainer && node.details.id == nodeId) {
        root.addNewChange(
          [node.copyWith(children: [])],
          TreeOperation.clearChildren,
          root.clone(),
        );
        node
          ..clear()
          ..openOrClose(forceOpen: true);
        TreeLogger.internalNodes.debug(
          'Node(id: ${node.id}, level: ${node.level}, parent: ${node.owner ?? 'no-parent'}) was cleared',
        );
        break;
      } else if (node is NodeContainer && node.isNotEmpty) {
        final shouldBreak = clearChildrenHelper(nodeId, node);
        if (shouldBreak) break;
      }
    }
  }

  @override
  int getFullCountOfChildrenInNode(NodeContainer? node, String? nodeId,
      {bool recursive = false}) {
    nodeId ??= '';
    if (nodeId.isNotEmpty) {
      if (!root.existNode(nodeId)) {
        throw NodeNotExistInTree(
          message:
              'The node $nodeId not exist into the tree currently. Please, ensure first if the node was removed before insert any node',
          node: nodeId,
        );
      }
    }
    final NodeContainer<Node> container =
        node ?? getNodeById(nodeId) as NodeContainer;
    int nodesCount = container.length;

    void recursiveNodeSearch(NodeContainer composite) {
      for (var subNode in composite.children) {
        nodesCount++;
        if (subNode is NodeContainer && subNode.isNotEmpty) {
          recursiveNodeSearch(subNode);
        }
      }
    }

    if (recursive) recursiveNodeSearch(container);

    return nodesCount;
  }

  @override
  List<Node>? getAllNodeMatches(bool Function(Node node) predicate) {
    final Set<Node> matchedNodes = {};

    void matchNode(List<Node> children) {
      for (var node in children) {
        if (predicate(node)) {
          matchedNodes.add(node);
        } else if (node is NodeContainer && node.isNotEmpty) {
          matchNode(node.children);
        }
      }
    }

    matchNode(root.children);

    return matchedNodes.toList();
  }

  @override
  Node? getNodeWhere(bool Function(Node node) predicate) {
    Node? foundedNode;

    bool searchNode(List<Node> children) {
      for (var node in children) {
        if (predicate(node)) {
          foundedNode = node;
          return true;
        } else if (node is NodeContainer && node.isNotEmpty) {
          final wasFounded = searchNode(node.children);
          if (wasFounded) return true;
        }
      }
      return false;
    }

    searchNode(root.children);

    return foundedNode;
  }

  @override
  List<Node>? getAllChildrenInNode(String nodeId) {
    verifyState();
    NodeContainer? node;
    for (var treenode in root.children) {
      if (treenode is NodeContainer && treenode.details.id == nodeId) {
        node = treenode;
      } else if (treenode is NodeContainer && treenode.isNotEmpty) {
        node = getMultiNodeHelper(nodeId, compositeNode: treenode);
      }
    }
    if (node != null) return [...node.children];

    throw InvalidNodeId(
      message:
          'The gived node: $nodeId is not founded on any part of the tree. Please, ensure the node really exist into the Tree',
    );
  }

  @override
  Node? getNodeById(String nodeId) {
    verifyState();
    for (Node node in root.children) {
      if (node.details.id == nodeId) {
        return node;
      } else if (node is NodeContainer && node.isNotEmpty) {
        final targetNode =
            searchChild(node, NodeDetails.base(nodeId), SearchStrategy.target);
        if (targetNode != null) return targetNode;
      }
    }
    TreeLogger.internalNodes.error(
      'Node(id: $nodeId) not exist into the Node Tree',
    );
    throw InvalidNodeId(
        message: 'Node(id: $nodeId) not exist into the Node Tree');
  }

  @override
  Node? childAfterThis(NodeDetails node, [int? indexNode]) {
    verifyState();
    final isRootLevel = node.level == -1 && node.id == root.details.id;
    if (isRootLevel && indexNode != null) {
      if (indexNode + 1 >= root.length) return null;
      return root.elementAt(indexNode + 1);
    } else {
      for (int i = 0; i < root.length; i++) {
        final treeNode = root.elementAt(i);
        if (treeNode.details.id == node.id) {
          if (i + 1 >= root.length) return null;
          return root.elementAt(i + 1);
        } else if (treeNode is NodeContainer && treeNode.isNotEmpty) {
          final nextNode = treeNode.childAfterThis(node, true, indexNode);
          if (nextNode != null) return nextNode;
        }
      }
    }
    return null;
  }

  /// selectNode just makes of the tree directory
  /// select a node
  void selectNode(Node? node) {
    verifyState();
    if (currentSelectedNode.value?.details == node?.details) return;
    TreeLogger.selection.debug(
        'Selected ${node.runtimeType}(id: ${node?.id.substring(0, 6)}, level: ${node?.level}, parent: ${node?.owner?.substring(0, 3) ?? 'no-parent'})');
    currentSelectedNode.value = node;
  }

  @override
  bool updateNodeAtWithCallback(String nodeId, Node Function(Node) callback) {
    for (int i = 0; i < root.length; i++) {
      final node = root.elementAt(i);
      if (node.id == nodeId) {
        var newChildState = callback(node);
        newChildState = newChildState.copyWith(
            details: newChildState.details
                .copyWith(level: node.level, owner: node.owner));
        // verify if the callback created by the dev
        // does not change the node value of the tree node
        if (newChildState.id != node.id) {
          throw InvalidCustomNodeBuilderCallbackReturn(
              message:
                  'Invalid custom node builded $newChildState. Please, ensure of create a TreeNode valid with the same Node of the passed as the argument',
              originalVersionNode: node,
              newNodeVersion: newChildState,
              reason:
                  'The Node of the TreeNode cannot be different than the original');
        }
        root.addNewChange(
          [newChildState],
          TreeOperation.update,
          node,
        );
        root[i] = newChildState;
        if (selectedNode?.id == newChildState.id) {
          selectNode(newChildState);
        }
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        final wasUpdated =
            updateSubNodesWithCallback(node.children, callback, nodeId);
        if (wasUpdated) {
          root[i] = node;
          return true;
        }
      }
    }
    return false;
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    root.dispose();
    _disposed = true;
  }
}
