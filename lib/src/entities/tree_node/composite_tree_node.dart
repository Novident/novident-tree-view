import 'package:collection/collection.dart';

import '../../interfaces/draggable_node.dart';
import '../node/node.dart';
import 'selectable_tree_node.dart';
import 'tree_node.dart';

/// [CompositeTreeNode] represents a node that can contains all
/// types of Nodes as its children
///
/// You can take this implementation as a directory from your
/// local storage that can contains a wide variety of file types
abstract class CompositeTreeNode<T extends TreeNode> extends SelectableTreeNode
    implements Draggable {
  final List<T> children;
  /// If expanded is true the [CompositeTreeNode]
  /// should show the children into it
  final bool isExpanded;

  CompositeTreeNode({
    required this.children,
    required super.node,
    required super.nodeParent,
    this.isExpanded = false,
  });

  @override
  CompositeTreeNode<T> copyWith(
      {Node? node, List<T>? children, bool? isExpanded, String? nodeParent});

  @override
  CompositeTreeNode<T> clone();

  @override
  String toString() {
    return 'CompositeTreeNode(Node: $node, parent: $nodeParent, isOpen: $isExpanded, $children)';
  }

  /// Fix an issue where the nodes of the children
  /// when a composite is moved to another part of the tree
  /// are not updated correctly
  void formatChildLevels(
      [List<TreeNode>? unformattedChildren, int? currentLevel]) {
    unformattedChildren ??= children;
    currentLevel ??= level;
    for (int i = 0; i < unformattedChildren.length; i++) {
      final node = unformattedChildren.elementAt(i);
      unformattedChildren[i] =
          node.copyWith(node: node.node.copyWith(level: currentLevel + 1));
      if (node is CompositeTreeNode && node.isNotEmpty) {
        formatChildLevels(node.children, currentLevel + 1);
      }
    }
  }

  /// Update the id of the parent of the children
  void updateInternalNodesByParentId(String newParentNode,
      [List<TreeNode>? nodes]) {
    nodes ??= children;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes.elementAt(i);
      nodes[i] = node.copyWith(nodeParent: newParentNode);
      if (node is CompositeTreeNode && node.isNotEmpty) {
        updateInternalNodesByParentId(newParentNode, node.children);
      }
    }
  }

  /// Check if the id of the node exist in the root
  /// of the [CompositeTreeNode] without checking into its children
  bool existInRoot(String nodeId) {
    for (int i = 0; i < length; i++)
      if (elementAt(i).node.id == nodeId) return true;
    return false;
  }

  /// Check if the id of the node exist into the [CompositeTreeNode]
  /// checking in its children without limitations
  ///
  /// This opertion could be heavy based on the deep of the nodes
  /// into the [CompositeTreeNode]
  bool existNode(String nodeId) {
    for (int i = 0; i < length; i++) {
      final node = elementAt(i);
      if (node.node.id == nodeId) {
        return true;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final foundedNode = node.existNode(nodeId);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  /// Check if the id of the node exist into the [CompositeTreeNode]
  /// checking in its children using a custom predicate passed by the dev
  ///
  /// This opertion could be heavy based on the deep of the nodes
  /// into the [CompositeTreeNode]
  bool existNodeWhere(bool Function(TreeNode node) predicate,
      [List<TreeNode>? subChildren]) {
    final currentChildren = subChildren;
    for (int i = 0; i < (currentChildren ?? this.children).length; i++) {
      final node = (currentChildren ?? this.children).elementAt(i);
      if (predicate(node)) {
        return true;
      } else if (node is CompositeTreeNode && node.isNotEmpty) {
        final foundedNode = existNodeWhere(predicate, node.children);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  TreeNode? backChild(Node node, bool alsoInChildren, [int? indexNode]) {
    if (indexNode != null) {
      final element = elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode == 0) return null;
        return elementAt(indexNode - 1);
      }
    }
    for (int i = 0; i < length; i++) {
      final treeNode = elementAt(i);
      if (treeNode.node.id == node.id) {
        if (i - 1 == -1) return null;
        return elementAt(i - 1);
      } else if (treeNode is CompositeTreeNode &&
          treeNode.isNotEmpty &&
          alsoInChildren) {
        final backNode = treeNode.backChild(node, alsoInChildren, indexNode);
        if (backNode != null) return backNode;
      }
    }
    return null;
  }

  TreeNode? nextChild(Node node, bool alsoInChildren, [int? indexNode]) {
    if (indexNode != null) {
      final element = elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode + 1 >= length) return null;
        return elementAt(indexNode + 1);
      }
    }
    for (int i = 0; i < length; i++) {
      final treeNode = elementAt(i);
      if (treeNode.node.id == node.id) {
        if (i + 1 >= length) return null;
        return elementAt(i + 1);
      } else if (treeNode is CompositeTreeNode &&
          treeNode.isNotEmpty &&
          alsoInChildren) {
        final nextChild = treeNode.nextChild(node, alsoInChildren, indexNode);
        if (nextChild != null) return nextChild;
      }
    }
    return null;
  }

  T elementAt(int index) {
    return children.elementAt(index);
  }

  T? elementAtOrNull(int index) {
    return children.elementAtOrNull(index);
  }

  bool contains(Object object) {
    return children.contains(object);
  }

  void clearAndOverrideState(List<T> newChildren) {
    clear();
    addAll(newChildren);
  }

  T get first => children.first;
  T get last => children.last;
  T? get lastOrNull => children.lastOrNull;
  T? get firstOrNull => children.firstOrNull;
  Iterator<T> get iterator => children.iterator;
  Iterable<T> get reversed => children.reversed;
  bool get isEmpty => children.isEmpty;
  bool get hasNoChildren => children.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => children.length;

  int indexWhere(bool Function(T) callback) {
    return children.indexWhere(callback);
  }

  int indexOf(T element, int start) {
    return children.indexOf(element, start);
  }

  T firstWhere(bool Function(T) callback) {
    return children.firstWhere(callback);
  }

  T lastWhere(bool Function(T) callback) {
    return children.lastWhere(callback);
  }

  void add(T element) {
    children.add(element);
  }

  void addAll(Iterable<T> children) {
    this.children.addAll(children);
  }

  void insert(int index, T element) {
    children.insert(index, element);
  }

  void clear() {
    children.clear();
  }

  bool remove(T element) {
    return children.remove(element);
  }

  T removeLast() {
    return children.removeLast();
  }

  void removeWhere(bool Function(T) callback) {
    children.removeWhere(callback);
  }

  T removeAt(int index) {
    return children.removeAt(index);
  }

  void operator []=(int index, T format) {
    if (index < 0) return;
    children[index] = format;
  }

  T operator [](int index) {
    return children[index];
  }

  @override
  bool canBePressed() {
    return true;
  }

  @override
  bool canBeSelected({bool isDraggingModeActive = false}) {
    return !isDraggingModeActive;
  }

  @override
  bool canDrag({bool isSelectingModeActive = false}) {
    return !isSelectingModeActive;
  }

  @override
  bool canDrop({required TreeNode target}) {
    return target is Draggable && target is CompositeTreeNode<T>;
  }
}
