## 📚 Nodes

_This example code is copied from [novident-nodes](https://github.com/Novident/novident-nodes/) package._
```dart
/// Abstract base class representing a node in a hierarchical tree structure.
///
/// This class combines notification capabilities ([NodeNotifier]), visitor pattern
/// support ([NodeVisitor]), and cloning functionality ([ClonableMixin]).
/// It serves as the foundation for all node types in the hierarchy.
abstract class Node extends NodeNotifier with NodeVisitor, ClonableMixin<Node> {
  /// Contains metadata and identification information about this node
  final NodeDetails details;

  /// Provides a link between layers in the rendering composition
  final LayerLink layer;

  Node({
    required this.details,
  }) : layer = LayerLink();
}
```

## Drag and Drop capability

This is the declaration of the main Mixin that allow to us the **Drag and Drop** feature.

```dart
/// Enables nodes to participate in drag-and-drop operations within the tree
///
/// Provides granular control over both drag initiation and drop acceptance
/// behavior for individual nodes in the hierarchy
mixin DragAndDropMixin {
  /// Determines if this node can initiate a drag operation
  ///
  /// Return `true` to allow dragging from this node
  bool isDraggable();

  /// Determines if this node can act as a drop target
  ///
  /// Return `true` to allow other nodes to be dropped onto this node
  bool isDropTarget();

  /// Determines if other nodes be inserted into the node
  ///
  /// Return `true` to allow other nodes to be dropped onto this node
  bool isDropIntoAllowed();

  /// Validates if a dragged node can be dropped at specific position
  ///
  /// - [draggedNode]: Node being dragged that want to be inserted into/below/above this
  /// - [dropPosition]: Target position relative to this node (above/inside/below)
  ///
  /// Return `true` to allow the drop operation at specified position
  bool isDropPositionValid(Node draggedNode, DragHandlerPosition dropPosition);
}
```
