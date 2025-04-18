import 'package:example/common/controller/extension/base_controller_helpers.dart';
import 'package:example/common/entities/root.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:example/common/extensions/num_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'base/base_tree_controller.dart';

/// The [`TreeController`] manages a tree of nodes, allowing for the manipulation and querying of its structure.
/// This includes the `insertion`, `deletion`, `updating`, and `movement` of nodes within the tree.
/// Additionally, it supports operations on node selections and notifies subscribers when there are changes in the tree.
class TreeController extends BaseTreeController {
  TreeController({required Root root}) : _root = root;

  final Root _root;

  @override
  Root get root => _root;

  /// Removes the current node selected
  void invalidateSelection() {
    selectNode(null);
  }

  void selectFirstNode() {
    if (isEmpty) return;
    selectNode(root.first);
  }

  void selectLastNode() {
    if (isEmpty) return;
    selectNode(root.last);
  }

  void insertAt(
    Node node,
    String nodeTargetId, {
    bool removeIfNeeded = false,
  }) {
    if (removeIfNeeded) {
      removeAt(node.id, verifyDuplicates: true, ignoreNotify: true);
    }

    bool existInRoot = root.existInRoot(node.id);
    if (root.id == nodeTargetId && !existInRoot) {
      if (node is NodeContainer && node.isNotEmpty) {
        node.redepthChildren(0);
      }
      Node newNodeState = node..owner = root;
      root.add(newNodeState);
      if (selectedNode?.id == node.id) {
        selectNode(newNodeState);
      }
    } else {
      for (int i = 0; i < root.length; i++) {
        Node nodeAtRootPoint = root.elementAt(i);
        if (nodeAtRootPoint.id == nodeTargetId) {
          if (nodeAtRootPoint is! NodeContainer) {
            throw Exception(
              'The node [${nodeAtRootPoint.runtimeType}-$nodeTargetId] is not a '
              'valid target to insert the ${node.runtimeType} into it. '
              'Please, ensure of the target node is a NodeContainer to '
              'allow insert nodes into itself correctly',
            );
          }
          if (!nodeAtRootPoint.existInRoot(node.id)) {
            if (node is NodeContainer) {
              node.redepthChildren();
            }
            Node validStateToNode = node.copyWith(
                details: node.details.copyWith(
              level: nodeAtRootPoint.level + 1,
              owner: nodeAtRootPoint,
            ));
            if (selectedNode?.id == node.id) {
              selectNode(
                validStateToNode,
              );
            }
            nodeAtRootPoint.asDirectory
              ..add(validStateToNode)
              ..openOrClose(forceOpen: true);
            return;
          } else {
            // is already inserted and doesn't need to be searched more
            return;
          }
        } else if (nodeAtRootPoint is NodeContainer &&
            nodeAtRootPoint.isNotEmpty) {
          bool inserted =
              insertNodeInSubContainer(nodeAtRootPoint, node, nodeTargetId);
          if (inserted) {
            return;
          }
        }
      }
    }
  }

  void insertAtRoot(Node node, {bool removeIfNeeded = false}) {
    if (removeIfNeeded) {
      removeAt(node.id, verifyDuplicates: true, ignoreNotify: true);
    }
    insertAt(node, root.details.id, removeIfNeeded: !removeIfNeeded);
    notifyListeners();
  }

  void insertAbove(
    Node node,
    String childBelowId, {
    bool removeIfNeeded = true,
  }) {
    if (!root.existNode(childBelowId)) {
      throw Exception(
        'The node $childBelowId not exist into the tree currently. '
        'Please, ensure first if the node was removed before insert any node',
      );
    }
    if (removeIfNeeded) {
      // removes the node from the tree
      // insert the node at the position
      removeWhere(
        (Node element) => element.details.id == node.details.id,
        ignoreNotify: true,
      );
    }
    for (int i = 0; i < root.length; i++) {
      Node belowNode = root.elementAt(i);
      if (belowNode.details.id == childBelowId) {
        int beforeIndex = (i - 1).zeroIfNegative;
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        Node validStateToNode = node.copyWith(
            details: node.details.copyWith(
          level: belowNode.level,
          owner: root,
        ));

        if (selectedNode?.id == node.id) {
          selectNode(validStateToNode);
        }
        root.insert(
          beforeIndex,
          validStateToNode,
        );
        break;
      } else if (belowNode is NodeContainer && belowNode.isNotEmpty) {
        bool inserted =
            insertAboveNodeInSubComposite(belowNode, node, childBelowId);
        if (inserted) break;
      }
    }
  }

  void insertBelow(
    Node node,
    String childBelowId, {
    bool removeIfNeeded = true,
  }) {
    if (!root.existNode(childBelowId)) {
      throw Exception(
        'The node $childBelowId not exist into the tree currently. '
        'Please, ensure first if the node was removed before insert any node',
      );
    }
    if (removeIfNeeded) {
      // removes the node from the tree
      // insert the node at the position
      removeWhere(
        (Node element) => element.id == node.id,
        verifyDuplicates: true,
        ignoreNotify: true,
      );
    }
    for (int i = 0; i < root.length; i++) {
      Node belowNode = root.elementAt(i);
      if (belowNode.details.id == childBelowId) {
        int effectiveIndex = i + 1;
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        Node validStateToNode = node.copyWith(
            details: node.details.copyWith(
          level: belowNode.level,
          owner: root,
        ));

        if (selectedNode?.id == node.id) {
          selectNode(validStateToNode);
        }
        if (effectiveIndex >= root.length) {
          root.add(validStateToNode);
          break;
        }
        root.insert(
          effectiveIndex,
          validStateToNode,
        );
        break;
      } else if (belowNode is NodeContainer && belowNode.isNotEmpty) {
        bool inserted =
            insertAboveNodeInSubComposite(belowNode, node, childBelowId);
        if (inserted) break;
      }
    }
  }

  void insertAtWithCallback(String? parentId, Node Function() callback,
      {bool removeIfNeeded = false}) {
    bool insertInRoot = parentId == null || parentId == root.id;
    Node node = callback();
    if (removeIfNeeded) {
      removeWhere((Node element) => element.id == node.id,
          verifyDuplicates: true);
    }
    if (insertInRoot) {
      Node nodeToRoot = node.copyWith(
          details: node.details.copyWith(
        level: 0,
        owner: root,
      ));
      root.add(nodeToRoot);
      // notify the tree and the new selection
      selectNode(
        nodeToRoot,
      );
      return;
    }
    for (int i = 0; i < root.length; i++) {
      Node nodeAtRootPoint = root.elementAt(i);
      if (nodeAtRootPoint is NodeContainer) {
        if (nodeAtRootPoint.id == parentId) {
          if (node is NodeContainer) {
            node.redepthChildren();
          }
          Node validStateToNewNode = node.copyWith(
              details: node.details.copyWith(
            level: nodeAtRootPoint.level + 1,
            owner: nodeAtRootPoint,
          ));
          nodeAtRootPoint.add(validStateToNewNode);
          if (selectedNode?.id == node.id) {
            // avoid notify listeners multiple times unnecesarily
            // setting [shouldNotifyListeners] to [true]
            selectNode(
              validStateToNewNode,
            );
            return;
          }
        } else if (nodeAtRootPoint.isNotEmpty) {
          bool inserted = insertAtInSubCompositeWithCallback(
              nodeAtRootPoint, callback, parentId);
          if (inserted) {
            nodeAtRootPoint.asDirectory.openOrClose(forceOpen: true);
            break;
          }
        }
      }
    }
  }

  bool expandAllUntilTarget(Node targetNode,
      {bool openTargetIfNeeded = false}) {
    assert(targetNode.level >= 0);

    Future<bool> expandNodeWhen(List<Node> tree,
        {bool ignoreBySubNode = false}) async {
      for (int i = 0; i < tree.length; i++) {
        Node node = tree.elementAt(i);
        // the target was founded
        if (node is NodeContainer &&
            node.id == targetNode.id &&
            openTargetIfNeeded &&
            node.details.level == 0) {}
        if (node is NodeContainer &&
            node.id == targetNode.id &&
            openTargetIfNeeded) {
          node.asDirectory.openOrClose(forceOpen: true);
        }
        if (node.id == targetNode.id) {
          return true;
        }
        if (node is NodeContainer && node.isNotEmpty) {
          bool founded =
              await expandNodeWhen(node.children, ignoreBySubNode: true);
          if (founded) {
            return true;
          }
        }
      }
      return false;
    }

    expandNodeWhen(root.children);
    return true;
  }

  bool updateNodeAt(Node targetNode, String nodeId) {
    for (int i = 0; i < root.length; i++) {
      Node node = root.elementAt(i);
      if (node.id == nodeId) {
        root[i] = targetNode;
        String? selectedNodeId = selectedNode?.id;
        if (selectedNodeId == null || selectedNodeId != targetNode.id) {
          return true;
        }
        selectNode(targetNode);
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        bool wasUpdated = updateSubNodes(node.children, targetNode, nodeId);
        if (wasUpdated) {
          root[i] = node;
          return true;
        }
      }
    }
    return false;
  }

  void clearTree() {
    root.clear();
  }

  Node? removeWhere(
    bool Function(Node node) predicate, {
    bool ignoreRoot = false,
    bool verifyDuplicates = false,
    bool ignoreNotify = false,
  }) {
    for (int i = 0; i < root.length; i++) {
      Node node = root.elementAt(i);
      if (predicate(node) && !ignoreRoot) {
        root.remove(node);
        if (selectedNode?.id == node.id && !ignoreNotify) {
          invalidateSelection();
        }
        if (!verifyDuplicates) return node;
      } else if (node is NodeContainer && node.isNotEmpty) {
        bool isFounded = removeChild(
          node,
          null,
          predicate,
          verifyDuplicates,
          ignoreNotify,
        );
        if (isFounded) {
          return node;
        }
      }
    }
    return null;
  }

  // when return true the parent need override the root parent of this composite
  @protected
  bool removeChild(
    NodeContainer containerNode,
    NodeDetails? target, [
    bool Function(Node)? predicate,
    bool verifyDuplicates = false,
    bool ignoreNotify = false,
  ]) {
    if (target == null && predicate == null) {
      throw Exception(
        'target param and predicate cannot be null at the same time. '
        'Please, provide one of them to continue with the '
        'expected behavior of this method.',
      );
    }
    for (int i = 0; i < containerNode.length; i++) {
      Node node = containerNode.elementAt(i);
      if (node.id == target?.id || predicate?.call(node) == true) {
        containerNode.remove(node);
        if (selectedNode?.id == node.id && !ignoreNotify) {
          invalidateSelection();
        }
        if (!verifyDuplicates) return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        bool foundedNode = removeChild(
          node,
          target,
          predicate,
          verifyDuplicates,
          ignoreNotify,
        );
        if (foundedNode) return true;
      }
    }
    return false;
  }

  Node? removeAt(
    String nodeId, {
    bool ignoreRoot = false,
    bool verifyDuplicates = false,
    bool ignoreNotify = false,
  }) {
    for (int i = 0; i < root.length; i++) {
      Node node = root.elementAt(i);
      if (node.id == nodeId && !ignoreRoot) {
        root.remove(node);
        if (selectedNode?.id == node.id && !ignoreNotify) {
          selectNode(null);
        }
        return node;
      } else if (node is NodeContainer && node.isNotEmpty) {
        bool isFounded = removeChild(
          node,
          NodeDetails.base(nodeId),
          null,
          false,
          ignoreNotify,
        );
        if (isFounded) {
          return node;
        }
      }
    }
    return null;
  }
}
