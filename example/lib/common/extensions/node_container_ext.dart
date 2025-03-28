import 'dart:math';

import 'package:collection/collection.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// [NodeContainer] represents a node that can contains all
/// types of Nodes as its children
///
/// You can take this implementation as a directory from your
/// local storage that can contains a wide variety of file types
extension NodeContainerExt on NodeContainer {
  /// adjust the depth level of the children
  void redepthChildren([int? currentLevel]) {
    assert(level >= 0);
    void redepth(List<Node> unformattedChildren, int currentLevel) {
      currentLevel = level;
      for (int i = 0; i < unformattedChildren.length; i++) {
        final Node node = unformattedChildren.elementAt(i);
        if (node.isFile) {
          unformattedChildren[i] = node.asFile
              .copyWith(details: node.asFile.details.copyWith(level: currentLevel + 1));
        }
        if (node.isDirectory) {
          unformattedChildren[i] = node.asDirectory.copyWith(
              details: node.asDirectory.details.copyWith(level: currentLevel + 1));
        }
        if (node is NodeContainer && node.isNotEmpty) {
          redepth(node.children, currentLevel + 1);
        }
      }
    }

    redepth(
      children,
      currentLevel ?? level,
    );
    notifyListeners();
  }

  /// Update the id of the parent of the children
  void updateInternalNodesByParentId(String newParentNode,
      [List<Node>? nodes, bool shouldNotify = true]) {
    nodes ??= children;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes.elementAt(i);
      nodes[i] = node.copyWith(details: node.details.copyWith(owner: newParentNode));
      if (node is NodeContainer && node.isNotEmpty) {
        updateInternalNodesByParentId(newParentNode, node.children, false);
      }
    }
    if (shouldNotify) {
      notify();
    }
  }

  /// Check if the id of the node exist in the root
  /// of the [NodeContainer] without checking into its children
  bool existInRoot(String nodeId) {
    for (int i = 0; i < length; i++) if (elementAt(i).details.id == nodeId) return true;
    return false;
  }

  /// Check if the id of the node exist into the [NodeContainer]
  /// checking in its children without limitations
  ///
  /// This opertion could be heavy based on the deep of the nodes
  /// into the [NodeContainer]
  bool existNode(String nodeId) {
    for (int i = 0; i < length; i++) {
      final node = elementAt(i);
      if (node.details.id == nodeId) {
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        final foundedNode = node.existNode(nodeId);
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
  bool existNodeWhere(bool Function(Node node) predicate, [List<Node>? subChildren]) {
    final currentChildren = subChildren;
    for (int i = 0; i < (currentChildren ?? this.children).length; i++) {
      final node = (currentChildren ?? this.children).elementAt(i);
      if (predicate(node)) {
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        final foundedNode = existNodeWhere(predicate, node.children);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  Node? childBeforeThis(NodeDetails node, bool alsoInChildren, [int? indexNode]) {
    if (indexNode != null) {
      final element = elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode == 0) return null;
        return elementAt(indexNode - 1);
      }
    }
    for (int i = 0; i < length; i++) {
      final treeNode = elementAt(i);
      if (treeNode.details.id == node.id) {
        if (i - 1 == -1) return null;
        return elementAt(i - 1);
      } else if (treeNode is NodeContainer && treeNode.isNotEmpty && alsoInChildren) {
        final backNode = treeNode.childBeforeThis(node, alsoInChildren, indexNode);
        if (backNode != null) return backNode;
      }
    }
    return null;
  }

  Node? childAfterThis(NodeDetails node, bool alsoInChildren, [int? indexNode]) {
    if (indexNode != null) {
      final element = elementAtOrNull(indexNode);
      if (element != null) {
        if (indexNode + 1 >= length) return null;
        return elementAt(indexNode + 1);
      }
    }
    for (int i = 0; i < length; i++) {
      final treeNode = elementAt(i);
      if (treeNode.details.id == node.id) {
        if (i + 1 >= length) return null;
        return elementAt(i + 1);
      } else if (treeNode is NodeContainer && treeNode.isNotEmpty && alsoInChildren) {
        final nextChild = treeNode.childAfterThis(node, alsoInChildren, indexNode);
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
    notify();
  }

  void addAll(Iterable<T> children) {
    this.children.addAll(children);
    notify();
  }

  void insert(int index, T element) {
    children.insert(index, element);
    notify();
  }

  void clear() {
    children.clear();
    notify();
  }

  bool remove(T element) {
    final removed = children.remove(element);
    notify();
    return removed;
  }

  T removeLast() {
    final T value = children.removeLast();
    notify();
    return value;
  }

  void removeWhere(bool Function(T) callback) {
    children.removeWhere(callback);
    notify();
  }

  T removeAt(int index) {
    final T value = children.removeAt(index);
    notify();
    return value;
  }

  void operator []=(int index, T format) {
    if (index < 0) return;
    children[index] = format;
    notify();
  }

  T operator [](int index) {
    return children[index];
  }

  @override
  bool canDrag({bool isSelectingModeActive = false}) {
    return !isSelectingModeActive;
  }

  @override
  bool canDrop({required Node target}) {
    return target is MakeDraggable && target is NodeContainer<T>;
  }

  @override
  void dispose() {
    super.dispose();
    for (var e in children) {
      ChangeNotifier.debugAssertNotDisposed(this);
      e.dispose();
    }
  }
}
