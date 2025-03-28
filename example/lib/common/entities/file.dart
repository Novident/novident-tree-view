import 'package:example/common/entities/node_details.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class File extends Node {
  final String name;
  final String content;
  final DateTime createAt;
  final NodeDetails details;
  File({
    required this.details,
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
      dropPosition != DragHandlerPosition.into;

  @override
  bool isDropTarget() {
    return true;
  }

  @override
  String get id => details.id;

  @override
  int get level => details.level;

  @override
  NodeContainer<Node> get owner => details.owner!;

  @override
  set owner(NodeContainer<Node>? owner) {
    details.owner = owner;
    notifyListeners();
  }

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
  bool operator ==(covariant File other) {
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
}
