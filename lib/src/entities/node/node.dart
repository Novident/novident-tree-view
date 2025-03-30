import 'package:flutter/widgets.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:meta/meta.dart';

/// Abstract base class representing a node in a hierarchical tree structure
abstract class Node extends ChangeNotifier implements DragAndDropMixin {
  final List<Node> children;
  Node({
    List<Node>? children,
  }) : children = children ?? <Node>[];

  /// Unique identifier for the node
  ///
  /// Must be implemented to provide a stable identifier for:
  /// - State preservation
  /// - Drag-and-drop operations
  /// - Equality checks
  String get id;

  /// The depth level of the node in the tree hierarchy
  ///
  /// Example tree structure with levels:
  /// ```dart
  /// 0  1  2  3  // Levels
  /// A  ⋅  ⋅  ⋅   // Node A (level 0)
  /// └─ B  ⋅  ⋅   // Node B (level 1)
  /// ⋅  ├─ C  ⋅   // Node C (level 2)
  /// ⋅  │  └─ D   // Node D (level 3)
  /// ⋅  └─ E     // Node E (level 2)
  /// F  ⋅        // Node F (level 0)
  /// └─ G        // Node G (level 1)
  /// ```
  int get level;

  /// The parent container that owns this node
  Node? get owner;

  /// Determine if this nodes is considered as a container
  bool get isChildrenContainer;

  bool get isExpanded;

  @mustCallSuper
  void notify() {
    notifyListeners();
  }

  /// Indicates if the container has no child nodes
  bool get isEmpty => children.isEmpty;

  /// Indicates if the container has at least one child node
  bool get isNotEmpty => children.isNotEmpty;

  /// Updates the parent container relationship
  set owner(Node? owner);

  @override
  @mustCallSuper
  void dispose() {
    // Ensures proper cleanup of change notifier resources
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    super.dispose();
    if (isChildrenContainer) {
      for (final child in children) {
        child.dispose();
      }
    }
  }

  @override
  @mustBeOverridden
  bool operator ==(Object other);

  @override
  @mustBeOverridden
  int get hashCode;
}
