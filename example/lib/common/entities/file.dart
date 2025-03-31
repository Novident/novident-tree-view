import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class File extends Node implements DragAndDropMixin {
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
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => false;

  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) =>
      dropPosition == DragHandlerPosition.above ||
      dropPosition == DragHandlerPosition.below;

  @override
  bool isDropTarget() => true;

  @override
  File copyWith({
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
  bool operator ==(Object other) {
    if (other is! File) {
      return false;
    }
    return details == other.details &&
        content == other.content &&
        name == other.name &&
        createAt == other.createAt;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
        [
          details,
          content,
          name,
          createAt,
        ],
      );

  @override
  String toString() {
    return 'File(name: $name)';
  }

  @override
  File clone() {
    return File(
      details: details,
      content: content,
      name: name,
      createAt: createAt,
    );
  }

  @override
  int countAllNodes({required Predicate countNode}) {
    return 1;
  }

  @override
  int countNodes({required Predicate countNode}) {
    return 1;
  }

  @override
  bool deepExist(String id) {
    return this.id == id;
  }

  @override
  bool exist(String id) {
    return this.id == id;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'details': details.toJson(),
      'content': content,
      'createAt': createAt.millisecondsSinceEpoch,
    };
  }

  @override
  Node? visitAllNodes({required Predicate shouldGetNode}) {
    return shouldGetNode(this) ? this : null;
  }

  @override
  File? visitNode({required Predicate shouldGetNode}) {
    return shouldGetNode(this) ? this : null;
  }
}
