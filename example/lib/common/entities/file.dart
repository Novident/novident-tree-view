import 'package:example/common/entities/node_base.dart';
import 'package:example/common/entities/node_details.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class File extends NodeBase {
  final String name;
  final String content;
  final DateTime createAt;

  File({
    required super.details,
    required this.content,
    required this.name,
    required this.createAt,
  }) : super(
          children: <Node>[],
        );

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
  Node get owner => details.owner!;

  @override
  set owner(Node? owner) {
    if (owner != null && !owner.isChildrenContainer) {
      throw Exception('owner cannot be setted, since the owner '
          'always must implements Container interface');
    }
    details.owner = owner;
    notifyListeners();
  }

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

  @override
  bool get isChildrenContainer => false;

  @override
  bool get isExpanded => false;
}
