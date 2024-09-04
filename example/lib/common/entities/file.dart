import 'package:flutter_tree_view/flutter_tree_view.dart';

class File extends LeafTreeNode {
  final String name;
  final DateTime createAt;
  File({
    required super.node,
    required super.nodeParent,
    required this.name,
    required this.createAt,
  });

  @override
  bool canDrag({bool isSelectingModeActive = false}) {
    return !isSelectingModeActive;
  }

  @override
  bool canDrop({required TreeNode target}) {
    return target is CompositeTreeNode;
  }

  @override
  String toString() {
    return 'File(Node: $node, parent: $nodeParent, name: $name, create at: $createAt)';
  }

  @override
  TreeNode copyWith(
      {Node? node, String? nodeParent, String? name, DateTime? createAt}) {
    return File(
      node: node ?? this.node,
      nodeParent: nodeParent ?? this.nodeParent,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  List<Object?> get props => [node, nodeParent, name, createAt];

  @override
  File clone() {
    return File(
      node: node,
      nodeParent: nodeParent,
      name: name,
      createAt: createAt,
    );
  }
}
