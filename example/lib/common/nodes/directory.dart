import 'package:collection/collection.dart';
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
      if (child.owner != this) {
        child.owner = this;
      }
    }
    redepthChildren(checkFirst: true);
  }

  @override
  bool get isExpanded => _isExpanded;

  void openOrClose({bool forceOpen = false}) {
    _isExpanded = forceOpen ? true : !isExpanded;
    notify();
  }

  /// adjust the depth level of the children
  void redepthChildren({int? currentLevel, bool checkFirst = false}) {
    void redepth(List<Node> unformattedChildren, int currentLevel) {
      for (int i = 0; i < unformattedChildren.length; i++) {
        final Node node = unformattedChildren.elementAt(i);
        unformattedChildren[i] = node.cloneWithNewLevel(currentLevel + 1);
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
    notify();
  }

  set isExpanded(bool expand) {
    _isExpanded = expand;
    notify();
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
    return 'Directory(name: $name, isExpanded: $isExpanded, count nodes: ${children.length}, depth: $level)';
  }

  @override
  Directory clone({bool deep = true}) {
    return Directory(
      children: children,
      details: details,
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
    if (identical(this, other)) return true;
    return _equality.equals(children, other.children) &&
        name == other.name &&
        details == other.details &&
        createAt == other.createAt &&
        _isExpanded == other._isExpanded;
  }

  @override
  int get hashCode =>
      details.hashCode ^
      createAt.hashCode ^
      name.hashCode ^
      children.hashCode ^
      _isExpanded.hashCode;

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

  @override
  Directory cloneWithNewLevel(int level, {bool deep = true}) {
    return copyWith(
      children: children,
      isExpanded: isExpanded,
      name: name,
      createAt: createAt,
      details: details.cloneWithNewLevel(
        level,
      ),
    );
  }
}

const ListEquality<Node> _equality = ListEquality<Node>();
