## 🏹 Drag And Drop Details

The details of the **drag-and-drop** relationship of `NodeTargetBuilder` and `NodeDraggableBuilder`.

Details are created and updated when a node `draggedNode` starts being dragged or when it is hovering
another node `targetNode`.

Contains the exact position where the drop ocurred `globalDropPosition` as well
as the bounding box `targetBounds` with `globalTargetNodeOffset` of the target widget 
which enables many different ways for a node to adopt another node depending 
on where it was dropped.

### 🔎 Class Declaration

```dart
class NovDragAndDropDetails<T extends Node> with Diagnosticable {
  /// Creates a [NovDragAndDropDetails].
  const NovDragAndDropDetails({
    required this.draggedNode,
    required this.targetNode,
    required this.dropPosition,
    required this.targetBounds,
    required this.globalDropPosition,
    required this.globalTargetNodeOffset,
    this.candidateData = const [],
    this.rejectedData = const [],
  });

  /// The node that was dragged around and dropped on [targetNode].
  final T draggedNode;

  /// The node that received the drop of [draggedNode].
  final T targetNode;

  /// The exact hovering position of [draggedNode] inside [targetBounds].
  ///
  /// This can be used to decide what will happen to [draggedNode] once it is
  /// dropped at this vicinity of [targetBounds], whether it will become a
  /// child of [targetNode], a sibling, its parent, etc.
  final Offset dropPosition;

  /// The exact global hovering position of [draggedNode] inside [targetBounds].
  final Offset globalDropPosition;

  /// The exact global position of the targetBounds on the screen.
  final Offset globalTargetNodeOffset;

  /// The widget bounding box of [targetNode].
  ///
  /// This combined with [dropPosition] can be used to allow the user to drop
  /// the dragging node at different parts of the target node which could lead
  /// to different behaviors, e.g. drop as: previous sibling, first child, last
  /// child, next sibling, parent, etc.
  final Rect targetBounds;

  /// Contains the list of drag data that is hovering over the [TreeDragTarget]
  /// that that will be accepted by the [TreeDragTarget].
  ///
  /// This and [rejectedData] are collected from the data given to the builder
  /// callback of the [DragTarget] widget.
  final List<T?> candidateData;

  /// Contains the list of drag data that is hovering over this [TreeDragTarget]
  /// that will not be accepted by the [TreeDragTarget].
  ///
  /// This and [candidateData] are collected from the data given to the builder
  /// callback of the [DragTarget] widget.
  final List<dynamic> rejectedData;
}
```

### 💡 Useful method `mapDropPosition`

Determines the relative vertical position of a dragged node relative to a target widget
and returns a value based on the current drop position.

### 📊 Visual Representation of how works `mapDropPosition`

Take in account that the higher the `aboveZoneHeight`, the greater the range in which the upper zone of the `Node` will be detected, and the same goes for `belowZoneHeight`. In any case, the default values are sufficient to simulate the standard behavior of all `Node` trees (that accept **drag and drop**).

![Image](https://github.com/user-attachments/assets/ab95c634-f80f-4f23-b515-abcd70bd0d60)

### 📑 Properties 

| Property/Method        | Type/Default Value                     | Description |
|------------------------|----------------------------------------|-------------|
| `whenAbove`            | `P Function()`                         | Callback executed when node is in the upper threshold zone |
| `whenInside`           | `P Function()`                         | Callback executed when node is in the main content zone |
| `whenBelow`            | `P Function()`                         | Callback executed when node is in the lower threshold zone |
| `aboveZoneHeight`      | `double` (**default: 7 logical pixels**) | Size of the upper threshold zone |
| `belowZoneHeight`      | `double` (**default: 5.5 logical pixels**) | Size of the lower threshold zone |
| `ignoreAboveZone`      | `bool` (**default: false**)            | Determines if the above sections will be completely ignored |
| `ignoreInsideZone`     | `bool` (**default: false**)            | Determines if the inside sections will be completely ignored |
| `ignoreBelowZone`      | `bool` (**default: false**)            | Determines if the below sections will be completely ignored |

### 🔎 Method Signature

```dart
P? mapDropPosition<P>({
  required P Function() whenAbove,
  required P Function() whenInside,
  required P Function() whenBelow,
  bool ignoreInsideZone = false,
  bool ignoreAboveZone = false,
  bool ignoreBelowZone = false,
  double aboveZoneHeight = 7,
  double belowZoneHeight = 5,
});
```

