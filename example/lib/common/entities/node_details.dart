import 'dart:math';

import 'package:novident_tree_view/novident_tree_view.dart';

/// Represents a [NodeDetails] into the tree a make possible
/// identify it into tree and make operations with them
///
/// The level represents how depth is the [NodeDetails] into the Tree
/// The id is _(by default)_ an uuid generate using [generateIdV4] helper method
/// and must not be empty of have just whitespaces. It must be unique since let us
/// identify this [NodeDetails] from other Nodes
class NodeDetails implements Comparable<NodeDetails> {
  final int level;
  final String id;
  Node? owner;

  NodeDetails({
    required this.level,
    required this.id,
    this.owner,
  }) : assert(
            owner == null || owner.isChildrenContainer,
            'owner cannot have a isChildrenContainer '
            'that returns false');

  bool get hasNotOwner => owner == null;
  bool get hasOwner => !hasNotOwner;

  NodeDetails copyWith({
    int? level,
    String? id,
    Node? owner,
  }) {
    assert(owner == null || owner.isChildrenContainer);
    return NodeDetails(
      level: level ?? this.level,
      id: id ?? this.id,
      owner: owner ?? this.owner,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'id': id,
      'owner': owner,
    };
  }

  factory NodeDetails.base([String? id, Node? owner]) {
    assert(owner == null || owner.isChildrenContainer);
    return NodeDetails(
      level: 0,
      id: id ?? (Random.secure().nextInt(99999) * 50).toString(),
      owner: owner,
    );
  }

  factory NodeDetails.withLevel([int? level, Node? owner]) {
    level ??= 0;

    assert(owner == null || owner.isChildrenContainer);
    return NodeDetails(
      level: level,
      id: (Random.secure().nextInt(99999) * 50).toString(),
      owner: owner,
    );
  }

  factory NodeDetails.zero(Node? owner) {
    assert(owner == null || owner.isChildrenContainer);
    return NodeDetails(
      level: 0,
      id: (Random.secure().nextInt(99999) * 50).toString(),
      owner: owner,
    );
  }

  factory NodeDetails.fromJson(Map<String, dynamic> json) {
    return NodeDetails(
      level: json['level'],
      id: json['id'],
      owner: json['owner'],
    );
  }

  @override
  String toString() {
    return 'Level: $level, '
        'ID: ${id.substring(0, id.length < 4 ? id.length : 4)}, '
        'Owner: ${owner?.id.substring(0, id.length < 4 ? id.length : 4)}';
  }

  @override
  int compareTo(NodeDetails other) {
    return level < other.level
        ? -1
        : level > other.level
            ? 1
            : 0;
  }
}
