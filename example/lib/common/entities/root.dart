import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class Root extends NodeContainer<Node> {
  Root({
    required super.children,
  }) {
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
        if (node is File) {
          unformattedChildren[i] = node.copyWith(
            details: node.details.copyWith(level: currentLevel + 1),
          );
        }

        if (node is Directory) {
          unformattedChildren[i] = node.copyWith(
            details: node.details.copyWith(level: currentLevel + 1),
          );
        }
        if (node is NodeContainer && node.isNotEmpty) {
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
    notifyListeners();
  }

  @override
  bool operator ==(covariant Root other) {
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
  NodeContainer<Node>? get owner => null;

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

  @override
  set owner(NodeContainer<Node>? owner) {}
}
