import 'package:equatable/equatable.dart';

import '../node/node.dart';

abstract class TreeNode extends Equatable {
  final Node node;
  final String nodeParent;
  TreeNode({
    required this.node,
    required this.nodeParent,
  });

  String get id => node.id;
  int get level => node.level;

  TreeNode clone();
  TreeNode copyWith({Node? node, String? nodeParent});

  @override
  String toString() {
    return 'TreeNode(Node: $node, parent: $nodeParent)';
  }
}
