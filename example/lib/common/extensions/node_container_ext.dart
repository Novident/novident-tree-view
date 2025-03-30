import 'package:collection/collection.dart';
import 'package:example/common/entities/node_details.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// [NodeContainer] represents a node that can contains all
/// types of Nodes as its children
///
/// You can take this implementation as a directory from your
/// local storage that can contains a wide variety of file types
extension NodeContainerExt on Node {
  /// adjust the depth level of the children
  void redepthChildren([int? currentLevel]) {
    if (!isChildrenContainer) return;
    assert(level >= 0);
    void redepth(List<Node> unformattedChildren, int currentLevel) {
      currentLevel = level;
      for (int i = 0; i < unformattedChildren.length; i++) {
        final Node node = unformattedChildren.elementAt(i);
        unformattedChildren[i] = node.asBase.copyWith(
            details: node.asBase.details.copyWith(level: currentLevel + 1));
        if (node.isChildrenContainer && node.isNotEmpty) {
          redepth(node.children, currentLevel + 1);
        }
      }
    }

    redepth(
      children,
      currentLevel ?? level,
    );
    notify();
  }

  /// Check if the id of the node exist in the root
  /// of the [NodeContainer] without checking into its children
  bool existInRoot(String nodeId) {
    if (!isChildrenContainer) return false;
    for (int i = 0; i < length; i++) {
      if (elementAt(i).asBase.details.id == nodeId) return true;
    }
    return false;
  }

  /// Check if the id of the node exist into the [NodeContainer]
  /// checking in its children without limitations
  ///
  /// This opertion could be heavy based on the deep of the nodes
  /// into the [NodeContainer]
  bool existNode(String nodeId) {
    if (!isChildrenContainer) return false;
    for (int i = 0; i < length; i++) {
      final node = elementAt(i);
      if (node.asBase.details.id == nodeId) {
        return true;
      } else if (node.isChildrenContainer && node.isNotEmpty) {
        final bool foundedNode = node.existNode(nodeId);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  /// Check if the id of the node exist into the [NodeContainer]
  /// checking in its children using a custom predicate passed by the dev
  ///
  /// This opertion could be heavy based on the deep of the nodes
  /// into the [NodeContainer]
  bool existNodeWhere(bool Function(Node node) predicate,
      [List<Node>? subChildren]) {
    if (!isChildrenContainer) return false;
    final currentChildren = subChildren;
    for (int i = 0; i < (currentChildren ?? children).length; i++) {
      final Node node = (currentChildren ?? children).elementAt(i);
      if (predicate(node)) {
        return true;
      } else if (node.isChildrenContainer && node.isNotEmpty) {
        final bool foundedNode = existNodeWhere(predicate, node.children);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  Node? childBeforeThis(NodeDetails node, bool alsoInChildren,
      [int? indexNode]) {
    if (!isChildrenContainer) return null;
    if (indexNode != null) {
      final element = elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode == 0) return null;
        return elementAt(indexNode - 1);
      }
    }
    for (int i = 0; i < length; i++) {
      final treeNode = elementAt(i);
      if (treeNode.asBase.details.id == node.id) {
        if (i - 1 == -1) return null;
        return elementAt(i - 1);
      } else if (treeNode.isChildrenContainer &&
          treeNode.isNotEmpty &&
          alsoInChildren) {
        final backNode =
            treeNode.childBeforeThis(node, alsoInChildren, indexNode);
        if (backNode != null) return backNode;
      }
    }
    return null;
  }

  Node? childAfterThis(NodeDetails node, bool alsoInChildren,
      [int? indexNode]) {
    if (!isChildrenContainer) return null;
    if (indexNode != null) {
      final element = elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode + 1 >= length) return null;
        return elementAt(indexNode + 1);
      }
    }
    for (int i = 0; i < length; i++) {
      final treeNode = elementAt(i);
      if (treeNode.asBase.details.id == node.id) {
        if (i + 1 >= length) return null;
        return elementAt(i + 1);
      } else if (treeNode.isChildrenContainer &&
          treeNode.isNotEmpty &&
          alsoInChildren) {
        final nextChild =
            treeNode.childAfterThis(node, alsoInChildren, indexNode);
        if (nextChild != null) return nextChild;
      }
    }
    return null;
  }

  Node elementAt(int index) {
    if (!isChildrenContainer) return this;
    return children.elementAt(index);
  }

  Node? elementAtOrNull(int index) {
    if (!isChildrenContainer) return null;
    return children.elementAtOrNull(index);
  }

  bool contains(Object object) {
    if (!isChildrenContainer) return false;
    return children.contains(object);
  }

  void clearAndOverrideState(List<Node> newChildren) {
    if (!isChildrenContainer) return;
    clear();
    addAll(newChildren);
  }

  Node? get first {
    if (!isChildrenContainer) null;
    return children.first;
  }

  Node? get last {
    if (!isChildrenContainer) null;
    return children.last;
  }

  Node? get lastOrNull {
    if (!isChildrenContainer) return null;
    return children.lastOrNull;
  }

  Node? get firstOrNull {
    if (!isChildrenContainer) return null;
    return children.firstOrNull;
  }

  Iterator<Node>? get iterator {
    if (!isChildrenContainer) return null;
    return children.iterator;
  }

  Iterable<Node>? get reversed {
    if (!isChildrenContainer) return null;
    return children.reversed;
  }

  int get length => children.length;

  int indexWhere(bool Function(Node) callback) {
    if (!isChildrenContainer) return -1;
    return children.indexWhere(callback);
  }

  int indexOf(Node element, int start) {
    if (!isChildrenContainer) return -1;
    return children.indexOf(element, start);
  }

  Node? firstWhere(bool Function(Node) callback) {
    if (!isChildrenContainer) return null;
    return children.firstWhere(callback);
  }

  Node? lastWhere(bool Function(Node) callback) {
    if (!isChildrenContainer) return null;
    return children.lastWhere(callback);
  }

  void add(Node element) {
    if (!isChildrenContainer) return;
    if (element.owner != this && isChildrenContainer) {
      element.owner = this;
    }
    children.add(element);
    notify();
  }

  void addAll(Iterable<Node> children) {
    this.children.addAll(children);
    notify();
  }

  void insert(int index, Node element) {
    children.insert(index, element);
    notify();
  }

  void clear() {
    children.clear();
    notify();
  }

  bool remove(Node element) {
    final removed = children.remove(element);
    notify();
    return removed;
  }

  Node removeLast() {
    final Node value = children.removeLast();
    notify();
    return value;
  }

  void removeWhere(bool Function(Node) callback) {
    children.removeWhere(callback);
    notify();
  }

  Node removeAt(int index) {
    final Node value = children.removeAt(index);
    notify();
    return value;
  }

  void operator []=(int index, Node format) {
    if (index < 0) return;
    if (format.owner != this && isChildrenContainer) {
      format.owner = this;
    }
    children[index] = format;
    notify();
  }

  Node operator [](int index) {
    return children[index];
  }
}
