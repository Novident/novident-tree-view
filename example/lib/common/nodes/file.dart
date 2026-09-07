import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_split_view/novident_split_view.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// A document of the binder tree.
///
/// It carries NO content: every document's body lives in the
/// `DocumentContentStore` keyed by this node's id, so all the split
/// view panes showing it always read the same source of truth.
class File extends Node implements DragAndDropMixin, SplitDragAndDropMixin {
  final String name;
  final DateTime createAt;

  File({
    required super.details,
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
    DropPosition dropPosition,
  ) =>
      dropPosition != DropPosition.inside;

  @override
  bool isDropTarget() => true;

  @override
  bool isPaneDraggable() => true;

  @override
  bool isSplitZoneValid(SplitZone zone) => true;

  @override
  File copyWith({
    NodeDetails? details,
    String? name,
    DateTime? createAt,
  }) {
    return File(
      details: details ?? this.details,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! File) {
      return false;
    }
    if (identical(this, other)) return true;
    return details == other.details &&
        name == other.name &&
        createAt == other.createAt;
  }

  @override
  int get hashCode => details.hashCode ^ createAt.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'File(name: $name, depth: $level)';
  }

  @override
  File clone({bool deep = true}) {
    return File(
      details: details,
      name: name,
      createAt: createAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'details': details.toJson(),
      'createAt': createAt.millisecondsSinceEpoch,
    };
  }

  @override
  File cloneWithNewLevel(int level, {bool deep = true}) {
    return copyWith(
      details: details.cloneWithNewLevel(level),
    );
  }
}
