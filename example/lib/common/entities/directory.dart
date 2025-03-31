import 'package:example/common/entities/file.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class Directory extends NodeContainer implements DragAndDropMixin {
  final String name;
  final DateTime createAt;
  bool _isExpanded;

  Directory({
    required super.details,
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

  @override
  bool get isExpanded => _isExpanded;

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

  set isExpanded(bool expand) {
    _isExpanded = expand;
    notifyListeners();
  }

  @override
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => true;

  @override
  bool isDropPositionValid(draggedNode, DragHandlerPosition dropPosition) {
    return true;
  }

  @override
  bool isDropTarget() {
    return true;
  }

  @override
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

  @override
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
  bool operator ==(Object other) {
    if (other is! Directory) {
      return false;
    }
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
  Map<String, dynamic> toJson() {
    return {
      'details': details.toJson(),
      'createAt': createAt.millisecondsSinceEpoch,
      'name': name,
      'children': children.map((Node e) => e.toJson()).toList(),
      'isExpanded': _isExpanded,
    };
  }
}
