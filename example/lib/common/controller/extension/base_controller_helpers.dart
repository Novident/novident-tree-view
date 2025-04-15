import 'package:example/common/controller/base/base_tree_controller.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:example/common/extensions/num_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_nodes/novident_nodes.dart';

extension BaseControllerHelpers on BaseTreeController {
  bool insertNodeInSubContainer(
    NodeContainer container,
    Node node,
    String target,
  ) {
    for (int i = 0; i < container.length; i++) {
      var compositeNode = container.elementAt(i);
      if (compositeNode.id == target) {
        // when the user will insert a node the target need to be a compositeTreeNode
        if (compositeNode is! NodeContainer) {
          throw Exception(
            'The node [${compositeNode.runtimeType}-$target] is not a valid target to '
            'insert the ${node.runtimeType} into it. Please, ensure of the target '
            'node is a NodeContainer to allow insert nodes into itself correctly',
          );
        }
        if (!container.existInRoot(node.id)) {
          if (node is NodeContainer) {
            node.redepthChildren();
          }
          var validStateToNode = node.copyWith(
            details: node.details.copyWith(
              level: compositeNode.level + 1,
              owner: compositeNode,
            ),
          );
          if (selectedNode?.id == node.id) {
            selectNode(validStateToNode);
          }
          compositeNode.asDirectory
            ..add(validStateToNode)
            ..openOrClose(forceOpen: true);
          return true;
        } else {
          return true;
        }
      } else if (compositeNode is NodeContainer && compositeNode.isNotEmpty) {
        bool inserted = insertNodeInSubContainer(compositeNode, node, target);
        if (inserted) {
          compositeNode.asDirectory.openOrClose(forceOpen: true);
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
      if (belowNode.id == target) {
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        if (selectedNode?.id == node.id) {
          selectNode(
            node.copyWith(
              details: node.details.copyWith(
                level: belowNode.level,
                owner: container,
              ),
            ),
          );
        }
        container.insert(
          (i - 1).zeroIfNegative,
          node.copyWith(
            details: node.details.copyWith(
              level: belowNode.level,
              owner: container,
            ),
          ),
        );
        return true;
      } else if (belowNode is NodeContainer && belowNode.isNotEmpty) {
        bool inserted = insertAboveNodeInSubComposite(belowNode, node, target);
        if (inserted) return true;
      }
    }
    return false;
  }

  bool insertBelowNodeInSubComposite(
      NodeContainer container, Node node, String target) {
    for (int i = 0; i < container.length; i++) {
      final Node belowNode = container.elementAt(i);
      if (belowNode.id == target) {
        if (node is NodeContainer) {
          node.redepthChildren();
        }
        final Node effectiveNode = node.copyWith(
          details: node.details.copyWith(
            level: belowNode.level,
            owner: container,
          ),
        );
        if (selectedNode?.id == node.id) {
          selectNode(
            node.copyWith(
              details: node.details.copyWith(
                level: belowNode.level,
                owner: container,
              ),
            ),
          );
        }
        if (i + 1 > container.children.length) {
          container.add(effectiveNode);
          return true;
        }
        container.insert(
          i,
          effectiveNode,
        );
        return true;
      } else if (belowNode is NodeContainer && belowNode.isNotEmpty) {
        bool inserted = insertAboveNodeInSubComposite(belowNode, node, target);
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
    Node node = callback();
    for (int i = 0; i < compositeNode.length; i++) {
      Node treeNode = compositeNode.elementAt(i);
      if (treeNode is NodeContainer) {
        if (treeNode.id == parentId) {
          var nodeToInsert = node.copyWith(
            details: node.details.copyWith(
              level: treeNode.level + 1,
              owner: treeNode,
            ),
          );
          if (nodeToInsert is NodeContainer) {
            nodeToInsert.redepthChildren();
          }
          if (selectedNode?.id == nodeToInsert.id) selectNode(nodeToInsert);
          treeNode.add(nodeToInsert);
          return true;
        } else if (treeNode.isNotEmpty) {
          bool inserted =
              insertAtInSubCompositeWithCallback(treeNode, callback, parentId);
          if (inserted) {
            treeNode.asDirectory.openOrClose(forceOpen: true);
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
            children[index] = targetNode;
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
        Node newChildState = callback(child);
        newChildState = newChildState.copyWith(
          details: newChildState.details.copyWith(
            level: child.level,
            owner: child.owner,
          ),
        );
        // verify if the callback created by the dev
        // does not change the details value of the node
        if (newChildState.id != child.id) {
          throw Exception(
            'Invalid custom node builded ${newChildState.id} when as expected ${child.id}. Please, ensure of create a '
            'TreeNode valid with the same Node of the passed as the argument',
          );
        }
        children[index] = newChildState;
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
      if (node.id == nodeId) {
        return true;
      }
    }
    return false;
  }

  bool existNode(String nodeId) {
    for (int i = 0; i < root.length; i++) {
      var node = root.elementAt(i);
      if (node.id == nodeId) {
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
      if (treenode is NodeContainer && treenode.id == nodeId) {
        treenode.clear();
        return true;
      } else if (treenode is NodeContainer && treenode.isNotEmpty) {
        var shouldBreak = clearChildrenHelper(nodeId, treenode);
        if (shouldBreak) return shouldBreak;
      }
    }
    return false;
  }

  NodeContainer? getMultiNodeHelper(
    String nodeId, {
    NodeContainer? compositeNode,
  }) {
    verifyState();
    if (compositeNode != null) {
      for (Node treenode in compositeNode.children) {
        if (treenode is NodeContainer && treenode.id == nodeId) {
          return treenode;
        } else if (treenode is NodeContainer) {
          NodeContainer? container =
              getMultiNodeHelper(nodeId, compositeNode: treenode);
          if (container != null) return container;
        }
      }
    } else {
      for (var treenode in root.children) {
        if (treenode is NodeContainer && treenode.id == nodeId) {
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
