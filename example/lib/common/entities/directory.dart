import 'package:example/common/entities/file.dart';
import 'package:example/common/entities/node_details.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class Directory extends NodeContainer<Node> {
  final String name;
  final DateTime createAt;
  final NodeDetails details;

  bool _isExpanded;

  Directory({
    required this.details,
    required super.children,
    required this.name,
    required this.createAt,
    bool isExpanded = false,
  }) : _isExpanded = isExpanded {
    for (final Node child in children) {
      child.owner = this;
    }
    redepthChildren(checkFirst: true);
  }

  void openOrClose({bool forceOpen = false}) {
    _isExpanded = forceOpen ? true : !isExpanded;
    notifyListeners();
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
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => true;

  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) =>
      draggedNode.id != id && draggedNode.owner?.id != id;

  @override
  bool isDropTarget() {
    return true;
  }

  set isExpanded(bool expand) {
    _isExpanded = expand;
    notifyListeners();
  }

  Directory copyWith({
    NodeDetails? details,
    List<Node>? children,
    bool? isExpanded,
    String? name,
    DateTime? createAt,
  }) {
    return Directory(
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      details: details ?? this.details,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  String toString() {
    return 'Directory(name: $name, isExpanded: $isExpanded, children: ${children.length})';
  }

  Directory clone() {
    return Directory(
      children: children,
      details: NodeDetails.withLevel(level),
      isExpanded: _isExpanded,
      name: name,
      createAt: createAt,
    );
  }

  @override
  bool operator ==(covariant Directory other) {
    return listEquals(children, other.children) &&
        name == other.name &&
        details == other.details &&
        createAt == other.createAt &&
        _isExpanded == other._isExpanded;
  }

  @override
  int get hashCode => Object.hashAllUnordered([
        details,
        createAt,
        name,
        details,
        _isExpanded,
      ]);

  @override
  String get id => details.id;

  @override
  bool get isEmpty => children.isEmpty;

  @override
  bool get isExpanded => _isExpanded;

  @override
  int get level => details.level;

  @override
  NodeContainer<Node> get owner => details.owner!;

  @override
  set owner(NodeContainer<Node>? owner) {
    details.owner = owner;
    notifyListeners();
  }
}
