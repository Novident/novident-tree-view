import 'package:flutter/foundation.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/controller/base/base_tree_controller.dart';
import 'package:flutter_tree_view/src/utils/solve_invalid_update.dart';
import 'package:meta/meta.dart';

@internal
@experimental
extension BaseControllerHelpers on BaseTreeController {
  bool insertNodeInSubContainer(
      NodeContainer container, Node node, String target) {
    for (int i = 0; i < container.length; i++) {
      var compositeNode = container.elementAt(i);
      if (compositeNode.details.id == target) {
        // when the user will insert a node the target need to be a compositeTreeNode
        if (compositeNode is! NodeContainer) {
          throw InvalidTypeRef(
            message:
                'The node [${compositeNode.runtimeType}-$target] is not a valid target to insert the ${node.runtimeType} into it. Please, ensure of the target node is a NodeContainer to allow insert nodes into itself correctly',
            data: compositeNode,
            time: DateTime.now(),
            targetFail: target,
          );
        }
        if (!container.existInRoot(node.details.id)) {
          TreeLogger.internalNodes.debug(
            'Inserted ${node.runtimeType}(id: ${node.id.substring(0, 6)}, level: ${node.level}) node in ${container.runtimeType}(id: ${container.id}, level: ${container.level})',
          );
          if (node is NodeContainer) {
            node.redepthChildren();
          }
          root.addNewChange(
            [
              node.copyWith(
                  details: node.details.copyWith(owner: compositeNode.id))
            ],
            TreeOperation.insert,
            compositeNode,
          );
          var validStateToNode = node.copyWith(
            details: node.details.copyWith(
              level: compositeNode.level + 1,
              owner: compositeNode.id,
            ),
          );
          if (selectedNode?.id == node.id) {
            selectNode(validStateToNode);
          }
          compositeNode
            ..add(validStateToNode)
            ..openOrClose(forceOpen: true);
          return true;
        } else {
          return true;
        }
      } else if (compositeNode is NodeContainer && compositeNode.isNotEmpty) {
        var inserted = insertNodeInSubContainer(compositeNode, node, target);
        if (inserted) {
          compositeNode.openOrClose(forceOpen: true);
          return true;
        }
      }
    }
    return false;
  }

  bool insertAboveNodeInSubComposite(
      NodeContainer container, Node node, String target) {
    for (int i = 0; i < container.length; i++) {
      var belowNode = container.elementAt(i);
      if (belowNode.details.id == target) {
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        root.addNewChange([node], TreeOperation.insertAbove, container);
        if (selectedNode?.id == node.id) {
          selectNode(
            node.copyWith(
                details: node.details
                    .copyWith(level: belowNode.level, owner: container.id)),
          );
        }
        container.insert(
          i,
          node.copyWith(
              details: node.details.copyWith(
            level: belowNode.level,
            owner: container.id,
          )),
        );
        return true;
      } else if (belowNode is NodeContainer && belowNode.isNotEmpty) {
        var inserted = insertAboveNodeInSubComposite(belowNode, node, target);
        if (inserted) return true;
      }
    }
    return false;
  }

  @protected
  bool insertAtInSubCompositeWithCallback(
    NodeContainer compositeNode,
    Node Function() callback,
    String parentId,
  ) {
    var node = callback();
    for (int i = 0; i < compositeNode.length; i++) {
      var treeNode = compositeNode.elementAt(i);
      if (treeNode is NodeContainer) {
        if (treeNode.id == parentId) {
          var nodeToInsert = node.copyWith(
            details: node.details.copyWith(
              level: treeNode.level + 1,
              owner: treeNode.id,
            ),
          );
          if (nodeToInsert is NodeContainer) {
            nodeToInsert.redepthChildren();
          }
          root.addNewChange(
            [nodeToInsert],
            TreeOperation.insert,
            treeNode,
          );
          if (selectedNode?.id == nodeToInsert.id) selectNode(nodeToInsert);
          treeNode.add(nodeToInsert);
          return true;
        } else if (treeNode.isNotEmpty) {
          var inserted =
              insertAtInSubCompositeWithCallback(treeNode, callback, parentId);
          if (inserted) {
            treeNode.openOrClose(forceOpen: true);
            return true;
          }
        }
      }
    }
    return false;
  }

  @protected
  bool updateSubNodes(List<Node> children, Node targetNode, String nodeId) {
    bool updated = false;
    List<String> visited = <String>[];
    int i = 0;
    while (i < children.length) {
      Node child = children[i];
      if (child is NodeContainer) {
        if (!visited.contains(child.id)) {
          visited.add(child.id);
          if (child.id == nodeId) {
            int index = children.indexWhere((element) => element.id == nodeId);
            Reason invalidOperation =
                Reason.solveInvalidUpdate(child, targetNode);
            if (invalidOperation.reason != UNPROCESSED_REASON)
              throw InvalidNodeUpdate(reason: invalidOperation);
            root.addNewChange(
              [targetNode],
              TreeOperation.update,
              child,
            );
            children[index] = targetNode;
            TreeLogger.internalNodes.debug(
                '${targetNode.runtimeType}(id: ${targetNode.id.substring(0, 6)}) was updated into ${child.runtimeType}(id: ${child.id}) at index: $index at level: ${child.level}');
            if (selectedNode?.id == targetNode.id) {
              selectNode(targetNode);
            }
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
    List<Node> children,
    Node Function(Node) callback,
    String nodeId,
  ) {
    bool updated = false;
    int i = 0;
    while (i < children.length) {
      Node child = children.elementAt(i);
      if (child.id == nodeId) {
        int index = children.indexWhere((element) => element.id == nodeId);
        var newChildState = callback(child);
        newChildState = newChildState.copyWith(
            details: newChildState.details
                .copyWith(level: child.level, owner: child.owner));
        // verify if the callback created by the dev
        // does not change the details value of the node
        if (newChildState.details != child.details ||
            newChildState.id != child.id) {
          throw InvalidCustomNodeBuilderCallbackReturn(
              message:
                  'Invalid custom node builded $newChildState. Please, ensure of create a TreeNode valid with the same Node of the passed as the argument',
              originalVersionNode: child,
              newNodeVersion: newChildState,
              reason:
                  'The Node of the TreeNode cannot be different than the original');
        }
        root.addNewChange(
          [newChildState],
          TreeOperation.update,
          child,
        );
        children[index] = newChildState;
        TreeLogger.internalNodes.debug(
            '${newChildState.runtimeType}(id: ${newChildState.id.substring(0, 6)}) was updated into ${child.runtimeType}(id: ${child.id.substring(0, 6)}) at index: $index at level: ${child.level}');
        if (selectedNode?.id == newChildState.id) {
          selectNode(newChildState);
        }
        updated = true;
        return updated;
      } else if (child is NodeContainer && child.isNotEmpty) {
        updated = updateSubNodesWithCallback(child.children, callback, nodeId);
        if (updated) {
          break;
        }
      }
      i++;
    }
    return updated;
  }

  bool existInRoot(String nodeId) {
    for (int i = 0; i < root.length; i++) {
      var node = root.elementAt(i);
      if (node.details.id == nodeId) {
        return true;
      }
    }
    return false;
  }

  bool existNode(String nodeId) {
    for (int i = 0; i < root.length; i++) {
      var node = root.elementAt(i);
      if (node.details.id == nodeId) {
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        var foundedNode = node.existNode(nodeId);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  void verifyState() {
    ChangeNotifier.debugAssertNotDisposed(root);
    assert(!disposed,
        'This TreeController is no longer usable because it is already disposed');
  }

  bool clearChildrenHelper(String nodeId, NodeContainer node) {
    for (int index = 0; index < node.length; index++) {
      var treenode = node.elementAt(index);
      if (treenode is NodeContainer && treenode.details.id == nodeId) {
        root.addNewChange(
          [treenode],
          TreeOperation.clearChildren,
          node,
        );
        treenode.clear();
        TreeLogger.internalNodes.debug(
            '${treenode.runtimeType}(id: ${treenode.id.substring(0, 6)}) was cleared its children, into ${node.runtimeType}(id: ${node.id}) at index: $index at level: ${node.level}');
        return true;
      } else if (treenode is NodeContainer && treenode.isNotEmpty) {
        var shouldBreak = clearChildrenHelper(nodeId, treenode);
        if (shouldBreak) return shouldBreak;
      }
    }
    return false;
  }

  NodeContainer<Node>? getMultiNodeHelper(String nodeId,
      {NodeContainer<Node>? compositeNode}) {
    verifyState();
    if (compositeNode != null) {
      for (var treenode in compositeNode.children) {
        if (treenode is NodeContainer && treenode.details.id == nodeId) {
          return treenode;
        } else if (treenode is NodeContainer) {
          var container = getMultiNodeHelper(nodeId, compositeNode: treenode);
          if (container != null) return container;
        }
      }
    } else {
      for (var treenode in root.children) {
        if (treenode is NodeContainer && treenode.details.id == nodeId) {
          return treenode;
        } else if (treenode is NodeContainer && treenode.isNotEmpty) {
          var container = getMultiNodeHelper(nodeId, compositeNode: treenode);
          if (container != null) return container;
        }
      }
    }
    return null;
  }
}
