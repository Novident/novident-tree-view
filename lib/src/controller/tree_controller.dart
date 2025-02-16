import 'package:flutter/foundation.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/exceptions/invalid_operation.dart';
import 'package:flutter_tree_view/src/extensions/base_controller_helpers.dart';
import 'package:flutter_tree_view/src/utils/solve_invalid_update.dart';
import 'base/base_tree_controller.dart';

/// The [`TreeController`] manages a tree of nodes, allowing for the manipulation and querying of its structure.
/// This includes the `insertion`, `deletion`, `updating`, and `movement` of nodes within the tree.
/// Additionally, it supports operations on node selections and notifies subscribers when there are changes in the tree.
class TreeController extends BaseTreeController {
  TreeController(Iterable<Node> nodes) {
    root.addAll(nodes);
  }

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

  @override
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
      Node newNodeState = node.copyWith(
          details: node.details.copyWith(
        level: 0,
        owner: root.id,
      ));
      root.add(newNodeState);
      if (selectedNode?.id == node.id) {
        selectNode(newNodeState);
      }
    } else {
      for (int i = 0; i < root.length; i++) {
        Node nodeAtRootPoint = root.elementAt(i);
        if (nodeAtRootPoint.id == nodeTargetId) {
          if (nodeAtRootPoint is! NodeContainer) {
            throw InvalidTypeRef(
              message:
                  'The node [${nodeAtRootPoint.runtimeType}-$nodeTargetId] is not a '
                  'valid target to insert the ${node.runtimeType} into it. '
                  'Please, ensure of the target node is a NodeContainer to '
                  'allow insert nodes into itself correctly',
              data: nodeAtRootPoint,
              time: DateTime.now(),
              targetFail: nodeTargetId,
            );
          }
          if (!nodeAtRootPoint.existInRoot(node.id)) {
            if (node is NodeContainer) {
              node.redepthChildren();
            }
            Node validStateToNode = node.copyWith(
                details: node.details.copyWith(
              level: nodeAtRootPoint.level + 1,
              owner: nodeAtRootPoint.id,
            ));
            root.addNewChange(
              <Node>[validStateToNode],
              TreeOperation.insert,
              nodeAtRootPoint,
            );
            if (selectedNode?.id == node.id) {
              selectNode(
                validStateToNode,
              );
            }
            nodeAtRootPoint
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

  @override
  void insertAtRoot(Node node, {bool removeIfNeeded = false}) {
    if (removeIfNeeded)
      removeAt(node.id, verifyDuplicates: true, ignoreNotify: true);
    insertAt(node, root.details.id, removeIfNeeded: !removeIfNeeded);
    TreeLogger.root.debug(
      '${node.runtimeType}(id: ${node.id.substring(0, 6)}) was inserted into Root path',
    );
  }

  @override
  void insertAbove(
    Node node,
    String childBelowId, {
    bool removeIfNeeded = true,
  }) {
    if (!root.existNode(childBelowId)) {
      throw NodeNotExistInTree(
        message:
            'The node $childBelowId not exist into the tree currently. Please, ensure first if the node was removed before insert any node',
        node: childBelowId,
      );
    }
    if (removeIfNeeded) {
      // removes the node from the tree
      // insert the node at the position
      removeWhere(
        (Node element) => element.details.id == node.details.id,
        verifyDuplicates: true,
        ignoreNotify: true,
      );
    }
    for (int i = 0; i < root.length; i++) {
      Node belowNode = root.elementAt(i);
      if (belowNode.details.id == childBelowId) {
        int beforeIndex = (i - 1) == -1 ? 0 : i;
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        Node validStateToNode = node.copyWith(
            details: node.details.copyWith(
          level: belowNode.level,
          owner: root.id,
        ));

        root.addNewChange(
          <Node>[validStateToNode],
          TreeOperation.insertAbove,
          root,
        );
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

  @override
  void insertAtWithCallback(String? parentId, Node Function() callback,
      {bool removeIfNeeded = false}) {
    bool insertInRoot = parentId == null || parentId == id;
    Node node = callback();
    if (removeIfNeeded) {
      removeWhere((Node element) => element.id == node.id,
          verifyDuplicates: true);
    }
    if (insertInRoot) {
      Node nodeToRoot = node.copyWith(
          details: node.details.copyWith(
        level: 0,
        owner: root.id,
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
            owner: nodeAtRootPoint.id,
          ));
          root.addNewChange(
            <Node>[node, validStateToNewNode],
            TreeOperation.insert,
            nodeAtRootPoint,
          );
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
            nodeAtRootPoint.openOrClose(forceOpen: true);
            break;
          }
        }
      }
    }
  }

  @override
  void insertAllAt(
    List<Node> nodes,
    String nodeTargetId, {
    bool removeIfNeeded = false,
    bool verifyDuplicates = false,
  }) {
    for (Node node in nodes) {
      // removes if is necessary
      removeWhere(
        (Node element) => element.details.id == node.details.id,
        verifyDuplicates: verifyDuplicates,
      );
      insertAt(node, nodeTargetId);
    }
  }

  @override
  void insertAboveWithCallback(Node Function() callback, String childBelowId,
      {bool removeIfNeeded = false}) {
    if (!root.existNode(childBelowId)) {
      throw NodeNotExistInTree(
        message:
            'The node $childBelowId not exist into the tree currently. Please, ensure first if the node was removed before insert any node',
        node: childBelowId,
      );
    }
    Node node = callback();
    if (removeIfNeeded) {
      // removes the node from the tree
      // insert the node at the position
      removeWhere((Node element) => element.details.id == node.details.id,
          verifyDuplicates: true);
    }
    for (int i = 0; i < root.length; i++) {
      Node belowNode = root.elementAt(i);
      if (belowNode.details.id == childBelowId) {
        int beforeIndex = (i - 1) == -1 ? 0 : i;
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        Node validStateToNode = node.copyWith(
            details: node.details.copyWith(
          level: 0,
          owner: root.id,
        ));
        root.addNewChange(
          <Node>[node],
          TreeOperation.insertAbove,
          (root.clone())
            ..insert(
              beforeIndex,
              validStateToNode,
            ),
        );
        if (selectedNode?.id == node.id) {
          selectNode(validStateToNode);
        }
        root.insert(beforeIndex, validStateToNode);
        break;
      } else if (belowNode is NodeContainer && belowNode.isNotEmpty) {
        bool inserted =
            insertAboveNodeInSubComposite(belowNode, node, childBelowId);
        if (inserted) break;
      }
    }
  }

  @override
  void insertAllAbove(List<Node> nodes, String childBelowId,
      {bool removeIfNeeded = false, bool verifyDuplicates = false}) {
    for (Node node in nodes) {
      // removes if is necessary
      insertAbove(node, childBelowId, removeIfNeeded: true);
    }
  }

  @override
  bool expandAllUntilTarget(Node targetNode,
      {bool openTargetIfNeeded = false}) {
    assert(targetNode.level >= 0);
    bool ignoreBecauseIsSubNode = false;
    NodeContainer? compositeTreeNode;

    Future<bool> expandNodeWhen(List<Node> tree,
        {bool ignoreBySubNode = false}) async {
      ignoreBecauseIsSubNode = ignoreBySubNode;
      for (int i = 0; i < tree.length; i++) {
        Node node = tree.elementAt(i);
        // the target was founded
        if (node is NodeContainer &&
            node.id == targetNode.id &&
            openTargetIfNeeded &&
            node.details.level == 0) {
          compositeTreeNode = node..openOrClose(forceOpen: true);
        }
        if (node is NodeContainer &&
            node.id == targetNode.id &&
            openTargetIfNeeded) {
          node.openOrClose(forceOpen: true);
        }
        if (node.id == targetNode.id) {
          TreeLogger.internalNodes.debug(
            '${node.runtimeType}(id: ${node.id.substring(0, 6)}) forced to be opened by user interaction',
          );
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
    if (compositeTreeNode == null && !ignoreBecauseIsSubNode) {
      TreeLogger.internalNodes.warn(
        '${targetNode.runtimeType}(${targetNode.id}) was not founded into the tree',
      );
    }
    return true;
  }

  @override
  bool updateNodeAt(Node targetNode, String nodeId) {
    for (int i = 0; i < root.length; i++) {
      Node node = root.elementAt(i);
      if (node.id == nodeId) {
        Reason isInvalidUpdatedOp = Reason.solveInvalidUpdate(node, targetNode);
        if (isInvalidUpdatedOp.reason != UNPROCESSED_REASON)
          throw InvalidNodeUpdate(reason: isInvalidUpdatedOp);
        root.addNewChange(
          <Node>[targetNode],
          TreeOperation.update,
          node,
        );

        root[i] = targetNode;
        TreeLogger.root.debug(
            '${targetNode.runtimeType}(id: ${targetNode.id.substring(0, 6)}) was updated with a new state');
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

  @override
  void clearTree() {
    verifyState();
    root.addNewChange(<Node>[], TreeOperation.clearChildren);
    root.clear();
    TreeLogger.root.debug(
      'Root of the project was cleared',
    );
  }

  @override
  Node? removeWhere(
    bool Function(Node node) predicate, {
    bool ignoreRoot = false,
    bool verifyDuplicates = false,
    bool ignoreNotify = false,
  }) {
    for (int i = 0; i < root.length; i++) {
      Node node = root.elementAt(i);
      if (predicate(node) && !ignoreRoot) {
        root.addNewChange(
          <Node>[node],
          TreeOperation.delete,
        );
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
      throw const InvalidOperation(
          message:
              'target param and predicate cannot be null at the same time. '
              'Please, provide one of them to continue with the '
              'expected behavior of this method.',
          typeOp: 'Delete');
    }
    for (int i = 0; i < containerNode.length; i++) {
      Node node = containerNode.elementAt(i);
      if (node.details.id == target?.id || predicate?.call(node) == true) {
        root.addNewChange(
          <Node>[node],
          TreeOperation.delete,
          (containerNode.clone())..remove(node),
        );
        containerNode.remove(node);
        if (selectedNode?.id == node.id && !ignoreNotify) {
          invalidateSelection();
        }
        TreeLogger.internalNodes.debug(
          '${node.runtimeType}(id: ${node.id.substring(0, 6)}) was removed from '
          '${containerNode.runtimeType}(id: ${containerNode.id.substring(0, 6)}) at level: ${containerNode.level}, in index: $i',
        );
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

  @override
  Node? removeAt(
    String nodeId, {
    bool ignoreRoot = false,
    bool verifyDuplicates = false,
    bool ignoreNotify = false,
  }) {
    if (root.existInRoot(nodeId)) {
      int index = root.indexWhere((Node element) => element.id == nodeId);
      Node removedNode = root.removeAt(index);
      TreeLogger.root.debug(
        '${removedNode.runtimeType}(id: ${removedNode.id.substring(0, 6)}) was removed from the Root path',
      );
      if (!verifyDuplicates) return null;
    }
    for (int i = 0; i < root.length; i++) {
      Node node = root.elementAt(i);
      if (node.id == nodeId && !ignoreRoot) {
        root.addNewChange(
          <Node>[node],
          TreeOperation.delete,
        );
        root.remove(node);
        if (selectedNode?.id == node.id && !ignoreNotify) {
          selectNode(null);
        }
        TreeLogger.root.debug(
          '${node.runtimeType}(id: ${node.id.substring(0, 6)}) was removed from the Root path',
        );
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
