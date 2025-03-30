import 'package:example/common/entities/node_base.dart';
import 'package:example/common/entities/node_details.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class Root extends NodeBase {
  Root({
    required super.children,
  }) : super(details: NodeDetails(id: 'root', level: -1)) {
    for (final Node child in children) {
      child.owner = this;
    }
    redepthChildren(checkFirst: true);
  }

  /// adjust the depth level of the children
  void redepthChildren({int? currentLevel, bool checkFirst = false}) {
    void redepth(List<Node> unformattedChildren, int currentLevel) {
      for (int i = 0; i < unformattedChildren.length; i++) {
        final Node node = unformattedChildren.elementAt(i);
        unformattedChildren[i] = node.asBase.copyWith(
          details: node.asBase.details.copyWith(level: currentLevel + 1),
        );
        if (node.isChildrenContainer && node.isNotEmpty) {
          redepth(node.children, currentLevel + 1);
        }
      }
    }

    bool ignoreRedepth = false;
    if (checkFirst) {
      final int childLevel = level + 1;
      for (final child in children) {
        if (child.level != childLevel) {
          ignoreRedepth = true;
          break;
        }
      }
    }
    if (ignoreRedepth) return;

    redepth(children, currentLevel ?? level);
    notify();
  }

  @override
  bool operator ==(Object other) {
    if (other is! Root) {
      return false;
    }
    if (identical(this, other)) return true;
    return listEquals(children, other.children);
  }

  @override
  int get hashCode => children.hashCode;

  @override
  String get id => 'root';

  @override
  bool get isEmpty => children.isEmpty;

  @override
  bool get isExpanded => true;

  @override
  int get level => -1;

  @override
  Node? get owner => null;

  @override
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => true;

  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) =>
      draggedNode.level != 0;

  @override
  bool isDropTarget() {
    return true;
  }

  operator []=(int index, Node node) {
    if (node.owner != this) {
      node.owner = this;
    }
    children[index] = node;
    notify();
  }

  @override
  set owner(Node? owner) {}

  @override
  bool get isChildrenContainer => true;

  @override
  Root copyWith({NodeDetails? details}) {
    return this;
  }
}
