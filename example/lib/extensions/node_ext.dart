import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/common/nodes/root.dart';
import 'package:novident_nodes/novident_nodes.dart';

extension NodeExt on Node {
  bool get isContainer => this is NodeContainer;
  bool get isLeaf => !isContainer;
  bool get isFile => this is File;
  bool get isDirectory => this is Directory;
  bool get isRoot => this is Root;

  Directory get asDirectory => this as Directory;
  NodeContainer get asContainer => this as NodeContainer;
  File get asFile => this as File;
}

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
        unformattedChildren[i] = node.copyWith(
            details: node.details.copyWith(level: currentLevel + 1));
        if (node is NodeContainer && node.isNotEmpty) {
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
    for (int i = 0; i < length; i++) {
      if (elementAt(i).details.id == nodeId) return true;
    }
    return false;
  }

  /// Check if the id of the node exist into the [NodeContainer]
  /// checking in its children without limitations
  ///
  /// This opertion could be heavy based on the deep of the nodes
  /// into the [NodeContainer]
  bool existNode(String nodeId) {
    if (isEmpty) return false;
    for (int i = 0; i < length; i++) {
      final node = elementAt(i);
      if (node.details.id == nodeId) {
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
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
  bool existNodeWhere(
    bool Function(Node node) predicate, [
    List<Node>? subChildren,
  ]) {
    final List<Node>? currentChildren = subChildren;
    for (int i = 0; i < (currentChildren ?? children).length; i++) {
      final Node node = (currentChildren ?? children).elementAt(i);
      if (predicate(node)) {
        return true;
      } else if (node is NodeContainer && node.isNotEmpty) {
        final bool foundedNode = existNodeWhere(predicate, node.children);
        if (foundedNode) return true;
      }
    }
    return false;
  }

  int get length => children.length;
}
