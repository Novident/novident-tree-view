import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tree_view/src/utils/string.dart';
import '../../utils/uuid_generators.dart';

/// Represents a [NodeDetails] into the tree a make possible
/// identify it into tree and make operations with them
///
/// The level represents how depth is the [NodeDetails] into the Tree
/// The id is _(by default)_ an uuid generate using [generateIdV4] helper method
/// and must not be empty of have just whitespaces. It must be unique since let us
/// identify this [NodeDetails] from other Nodes
@immutable
class NodeDetails extends Equatable implements Comparable<NodeDetails> {
  final int level;
  final String id;
  final String? owner;

  NodeDetails({
    required this.level,
    required this.id,
    this.owner,
  })  : assert(
          id.isValidStringId(),
          'NodeDetails cannot have an empty id or an id with just whitespaces',
        ),
        assert(owner == null || owner.isValidStringId());

  bool get hasNotOwner => owner == null;
  bool get hasOwner => !hasNotOwner && owner!.isNotEmpty;

  /// Clone this object but with a new level value
  /// by default the level is [0]
  NodeDetails cloneWithNewLevel([int? level]) {
    level ??= 0;
    assert(level >= 0);
    return copyWith(level: level);
  }

  NodeDetails copyWith({int? level, String? id, String? owner}) {
    return NodeDetails(
        level: level ?? this.level,
        id: id ?? this.id,
        owner: owner ?? this.owner);
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'id': id,
      'owner': owner,
    };
  }

  factory NodeDetails.base([String? id, String? owner]) {
    return NodeDetails(
      level: 0,
      id: id ?? generateIdV4(),
      owner: owner,
    );
  }

  factory NodeDetails.withLevel([int? level, String? owner]) {
    level ??= 0;
    return NodeDetails(
      level: level,
      id: generateIdV4(),
      owner: owner,
    );
  }

  factory NodeDetails.zero(String owner) {
    return NodeDetails(
      level: 0,
      id: generateIdV4(),
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
        'Owner: ${owner?.substring(0, id.length < 4 ? id.length : 4)}';
  }

  @override
  int compareTo(NodeDetails other) {
    return level < other.level
        ? -1
        : level > other.level
            ? 1
            : 0;
  }

  @override
  List<Object?> get props => [level, id, owner];
}
