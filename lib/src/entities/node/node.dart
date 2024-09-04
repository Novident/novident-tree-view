import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../utils/uuid_generators.dart';

/// Represents a [Node] into the tree a make possible
/// identify it into tree and make operations with them
///
/// The level represents how depth is the [Node] into the Tree
/// The id is _(by default)_ an uuid generate using [generateIdV4] helper method
/// and must not be empty of have just whitespaces. It must be unique since let us
/// identify this [Node] from other Nodes
@immutable
class Node extends Equatable implements Comparable<Node> {
  final int level;
  final String id;

  Node({
    required this.level,
    required this.id,
  }) : assert(id.isNotEmpty && id.trim().isNotEmpty && id.replaceAll(RegExp(r'\p{Z}'), '').isNotEmpty,
            'Node cannot have an empty id or an id with just whitespaces');

  Node copyWith({
    int? level,
    String? id,
  }) {
    return Node(
      level: level ?? this.level,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'id': id,
    };
  }

  factory Node.base(String id) {
    return Node(
      level: 0,
      id: id,
    );
  }

  factory Node.withId([int? level]) {
    level ??= 0;
    return Node(
      level: level,
      id: generateIdV4(),
    );
  }

  factory Node.fromMap(Map<String, dynamic> json) {
    return Node(
      level: json['level'],
      id: json['id'],
    );
  }

  @override
  String toString() {
    return 'Level: $level, ${id.substring(0, id.length < 4 ? id.length : 4)}';
  }

  @override
  int compareTo(Node other) {
    return level < other.level
        ? -1
        : level > other.level
            ? 1
            : 0;
  }

  @override
  List<Object?> get props => [level, id];
}
