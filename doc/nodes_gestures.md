# 🖱️ Node Drag Gestures 

Defines all the callback handlers for drag-and-drop operations involving `Node` classes.

`NodeDragGestures` is an immutable class encapsulates all the possible interactions during a **drag-and-drop**
operation, including start, move, update, completion, cancellation, and acceptance events.
Each callback corresponds to a specific phase in the **drag-and-drop** lifecycle.

## 🏗️ Core Structure

### 🔧 Configurable Callbacks
| Callback | Type | Description |
|----------|------|-------------|
| `onDragStart` | `Function(Offset, Node)?` | Called when drag operation initiates |
| `onDragMove` | `Function(DragTargetDetails<Node>)?` | Called during node movement |
| `onDragUpdate` | `Function(DragUpdateDetails)?` | Updates drag position (default updates controller) |
| `onDragEnd` | `Function(DraggableDetails)?` | Called when drag completes (default resets controller) |
| `onDragCanceled` | `Function(Velocity, Offset)?` | Called when drag is canceled (default resets controller) |
| `onLeave` | `Function(Node)?` | Called when dragged node leaves target |
| `onDragCompleted` | `Function(Node)?` | Called when drag successfully completes (default resets controller) |
| `onWillAcceptWithDetails` | `Function(NovDragAndDropDetails<Node>?, DragTargetDetails<Node>, Node?)` | **(Required)** Validates drop acceptance |
| `onAcceptWithDetails` | `Function(NovDragAndDropDetails<Node>, Node?)` | **(Required)** Handles accepted drops |

## 🔄 Typical Usage

```dart
const NodeDragGestures(
  onWillAcceptWithDetails: (NovDragAndDropDetails<Node>? details, DragTargetDetails<Node> dragDetails, Node? parent ) {
    // Custom validation logic
    return details?.draggedNode != parent?.node;
  },
  onAcceptWithDetails: (NovDragAndDropDetails<Node> details, Node? parent) {
    // Handle successful drop
    final draggedNode = details.draggedNode;
    final position = details.handlerPosition;
    // Perform node insertion/movement
  },
  onDragStart: (Offset offset, Node node) {
    debugPrint('Dragging started: ${node.details.id}');
  },
  onDragEnd: (DraggableDetails details) {
    debugPrint('Drag operation completed');
  },
);
```
