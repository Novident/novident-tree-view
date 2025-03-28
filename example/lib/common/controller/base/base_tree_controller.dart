import 'package:example/common/controller/extension/base_controller_helpers.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/common/extensions/node_container_ext.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

abstract class BaseTreeController extends ChangeNotifier {
  Root get root;

  bool get isEmpty => root.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => root.children.length;

  bool _disposed = false;

  bool get disposed => _disposed;

  @protected
  ValueNotifier<Node?> currentSelectedNode = ValueNotifier(null);

  ValueNotifier<Node?> get selection => currentSelectedNode;

  set children(List<Node> newRoot) {
    root.clearAndOverrideState(newRoot);
    // reload the visual selection since the new root couldn't contain
    // the current node in selection
    selectNode(null);
  }

  Node? get selectedNode => currentSelectedNode.value;

  List<Node>? getAllNodeMatches(bool Function(Node node) predicate) {
    final Set<Node> matchedNodes = {};

    void matchNode(List<Node> children) {
      for (var node in children) {
        if (predicate(node)) {
          matchedNodes.add(node);
        } else if (node.isChildrenContainer && node.isNotEmpty) {
          matchNode(node.children);
        }
      }
    }

    matchNode(root.children);

    return matchedNodes.toList();
  }

  Node? getNodeWhere(bool Function(Node node) predicate) {
    Node? foundedNode;

    bool searchNode(List<Node> children) {
      for (var node in children) {
        if (predicate(node)) {
          foundedNode = node;
          return true;
        } else if (node.isChildrenContainer && node.isNotEmpty) {
          final wasFounded = searchNode(node.children);
          if (wasFounded) return true;
        }
      }
      return false;
    }

    searchNode(root.children);

    return foundedNode;
  }

  List<Node>? getAllChildrenInNode(String nodeId) {
    Node? node;
    for (var treenode in root.children) {
      if (treenode.isChildrenContainer &&
          treenode.asBase.details.id == nodeId) {
        node = treenode;
      } else if (treenode.isChildrenContainer && treenode.isNotEmpty) {
        node = getMultiNodeHelper(nodeId, compositeNode: treenode);
      }
    }
    if (node != null) return [...node.children];

    throw Exception(
      'The gived node: $nodeId is not founded on any part of the tree. '
      'Please, ensure the node really exist into the Tree',
    );
  }

  /// selectNode just makes of the tree directory
  /// select a node
  void selectNode(Node? node) {
    if (currentSelectedNode.value?.asBase.details == node?.asBase.details)
      return;
    currentSelectedNode.value = node;
  }

  bool updateNodeAtWithCallback(String nodeId, Node Function(Node) callback) {
    for (int i = 0; i < root.length; i++) {
      final node = root.elementAt(i);
      if (node.id == nodeId) {
        var newChildState = callback(node);
        newChildState = newChildState.asBase.copyWith(
          details: newChildState.asBase.details.copyWith(
            level: node.level,
            owner: node.owner,
          ),
        );
        // verify if the callback created by the dev
        // does not change the node value of the tree node
        if (newChildState.id != node.id) {
          throw Exception(
            'Invalid custom node builded $newChildState. Please, ensure of create a '
            'TreeNode valid with the same '
            'Node of the passed as the argument',
          );
        }
        root[i] = newChildState;
        if (selectedNode?.id == newChildState.id) {
          selectNode(newChildState);
        }
        return true;
      } else if (node.isChildrenContainer && node.isNotEmpty) {
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
