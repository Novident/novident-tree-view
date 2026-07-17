# 🖱️ Node Drag Gestures

`NodeDragGestures` encapsulates all the callbacks for drag‑and‑drop
operations involving `Node` objects — start, move, update, completion,
cancellation, and acceptance.

Each callback corresponds to a specific phase in the drag‑and‑drop
lifecycle. The two **required** callbacks (`onWillAcceptWithDetails`
and `onAcceptWithDetails`) control whether and how a drop is handled.

## 🏗️ Core Structure

### 📋 Required callbacks

| Callback | Signature | Purpose |
|---|---|---|
| `onWillAcceptWithDetails` | `bool Function(NovDragAndDropDetails<Node>?, DragTargetDetails<Node>, Node target, NodeContainer? parent)` | Validate whether a drop is allowed. Return `true` to accept, `false` to reject. |
| `onAcceptWithDetails` | `void Function(NovDragAndDropDetails<Node>, Node target, NodeContainer? parent)` | Handle the accepted drop — insert, move, or reorder the node. |

### 🔧 Optional callbacks

| Callback | Signature | Trigger |
|---|---|---|
| `onDragStart` | `void Function(Offset offset, Node node)` | Drag operation initiates. |
| `onDragUpdate` | `void Function(DragUpdateDetails details)` | Pointer moves during a drag. |
| `onDragMove` | `void Function(DragTargetDetails<Node> details)` | Dragged node moves over a potential drop target. |
| `onDragEnd` | `void Function(DraggableDetails)` | Pointer is released (drag completes or is dropped). |
| `onDragCanceled` | `void Function(Velocity velocity, Offset point)` | Drag is cancelled (e.g. Esc key). |
| `onLeave` | `void Function(Node data)` | Dragged node leaves a drop target without being dropped. |
| `onDragCompleted` | `void Function(Node node)` | Drag completed successfully (node was dropped and accepted). |

Note: `onDragEnd` fires for **every** pointer release (dropped *and*
cancelled). Use `onDragCompleted` for the "success" path specifically.

## 🔄 Typical Usage

### Full custom callbacks

```dart
const NodeDragGestures(
  onWillAcceptWithDetails: (
    NovDragAndDropDetails<Node>? details,
    DragTargetDetails<Node> dragDetails,
    Node target,
    NodeContainer? parent,
  ) {
    // Custom validation logic
    return details?.draggedNode != target;
  },
  onAcceptWithDetails: (
    NovDragAndDropDetails<Node> details,
    void Function(Node node, NodeContainer newOwner, int level)? onWillInsert,
    Node target,
    NodeContainer? parent,
  ) {
    // Handle successful drop
    final DropPosition? position = details.exactPosition();
    final Node dragged = details.draggedNode;
    // Perform node insertion/move based on position
  },
  onDragStart: (Offset offset, Node node) {
    debugPrint('Dragging started: ${node.details.id}');
  },
  onDragEnd: (DraggableDetails details) {
    debugPrint('Drag operation ended');
  },
);
```

### Standard file‑tree behaviour (recommended)

`NodeDragGestures.standardDragAndDrop()` provides sensible defaults
for a file‑tree‑like drag‑and‑drop experience:

```dart
NodeDragGestures.standardDragAndDrop(
  onWillInsert: (Node node, NodeContainer owner, int level) {
    // Called BEFORE the node is inserted into its new parent.
    // Use this to update external state that depends on
    // the node's owner or level (e.g. a selection controller).
    if (node is File && selectedNode?.id == node.id) {
      selectedNode = node.copyWith(
        details: node.details.copyWith(owner: owner, level: level),
      );
    }
  },
);
```

All standard callbacks accept optional overrides — only provide
the ones you need; the rest fall back to sensible defaults:

```dart
factory NodeDragGestures.standardDragAndDrop({
  NovOnWillAcceptOnNode? onWillAcceptWithDetails,
  void Function(Node node, NodeContainer newOwner, int level)? onWillInsert,
  void Function(DragTargetDetails<Node> details)? onDragMove,
  void Function(Offset offset, Node node)? onDragStart,
  void Function(DragUpdateDetails details)? onDragUpdate,
  void Function(Node data)? onLeave,
  void Function(DraggableDetails)? onDragEnd,
  void Function(Velocity velocity, Offset point)? onDragCanceled,
  void Function(Node node)? onDragCompleted,
})
```
