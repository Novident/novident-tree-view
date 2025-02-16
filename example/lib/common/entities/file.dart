import 'package:flutter_tree_view/flutter_tree_view.dart';

class File extends LeafNode {
  final String name;
  final String content;
  final DateTime createAt;
  File({
    required super.details,
    required this.content,
    required this.name,
    required this.createAt,
  });

  @override
  bool canDrag() {
    return true;
  }

  @override
  bool canDrop({required Node target}) {
    return target is NodeContainer;
  }

  @override
  String toString() {
    return 'File(name: $name)';
  }

  @override
  Node copyWith({
    NodeDetails? details,
    String? name,
    DateTime? createAt,
    String? content,
  }) {
    return File(
      details: details ?? this.details,
      content: content ?? this.content,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  List<Object?> get props => [
        details,
        name,
        createAt,
        content,
      ];

  @override
  File clone() {
    return File(
      details: NodeDetails.withLevel(level),
      content: content,
      name: name,
      createAt: createAt,
    );
  }
}
