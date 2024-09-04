import 'package:flutter_tree_view/flutter_tree_view.dart';

class Directory extends CompositeTreeNode<TreeNode> {
  final String name;
  final DateTime createAt;

  Directory({
    required super.children,
    required super.node,
    super.isExpanded,
    required super.nodeParent,
    required this.name,
    required this.createAt,
  });

  @override
  Directory copyWith({
    Node? node,
    List<TreeNode>? children,
    bool? isExpanded,
    String? nodeParent,
    String? name,
    DateTime? createAt,
  }) {
    return Directory(
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      node: node ?? this.node,
      nodeParent: nodeParent ?? this.nodeParent,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  List<Object?> get props =>
      [node, children, isEmpty, nodeParent, name, createAt];

  @override
  String toString() {
    return 'Directory(Node: $node, children: $children, isOpen: $isExpanded, parent: $nodeParent, name: $name, create at: $createAt)';
  }

  @override
  Directory clone() {
    return Directory(
      children: children,
      node: node,
      nodeParent: nodeParent,
      name: name,
      createAt: createAt,
    );
  }
}
