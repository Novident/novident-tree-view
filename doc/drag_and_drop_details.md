## 🏹 Drag And Drop Details

`NovDragAndDropDetails` is the data object produced and updated during a
drag‑and‑drop operation. It is created when a dragged node (`draggedNode`)
hovers over a potential drop target (`targetNode`).

It contains positional data (local and global offsets, the target's
bounding box) so builders can compute **where** inside the target the
user intends to drop — and therefore **what operation** to perform
(insert before, insert after, insert as child, etc.).

### 🔎 Class Declaration

```dart
class NovDragAndDropDetails<T extends Node> {
  const NovDragAndDropDetails({
    required this.draggedNode,
    required this.targetNode,
    required this.dropPosition,
    required this.targetBounds,
    required this.globalDropPosition,
    required this.globalTargetNodeOffset,
    this.candidateData = const [],
    this.rejectedData = const <dynamic>[],
    this.topZoneHeight = 7,
    this.bottomZoneHeight = 5.5,
  });

  final T draggedNode;
  final T targetNode;
  final Offset dropPosition;            // local (inside targetBounds)
  final Offset globalDropPosition;      // screen‑space
  final Offset globalTargetNodeOffset;  // top‑left of target in screen space
  final Rect targetBounds;              // size + position of the target widget
  final double topZoneHeight;           // height of the "above" sensitive band
  final double bottomZoneHeight;        // height of the "below" sensitive band
  final List<T?> candidateData;         // data accepted by the DragTarget
  final List<dynamic> rejectedData;     // data rejected by the DragTarget
}
```

### 💡 Useful methods

#### `DropPosition? exactPosition()`

Returns the current zone as an enum value:

```dart
final DropPosition? pos = details.exactPosition();
// DropPosition.above  → user is in the upper band
// DropPosition.inside → user is in the middle
// DropPosition.below  → user is in the lower band
// null                → pointer is outside the target's vertical bounds
```

#### `bool isDragging()`

Returns `true` while any zone is active (pointer is inside the
target's vertical bounds). Shorthand for `exactPosition() != null`.

#### `P? mapDropPosition<P>(…)`

The core method for rendering drop‑zone feedback. Maps the pointer's
vertical position to a typed result:

```dart
final border = details.mapDropPosition<BoxBorder?>(
  whenAbove:  () => Border(top: blueBorder),
  whenInside: () => Border.fromBorderSide(blueBorder),
  whenBelow:  () => Border(bottom: blueBorder),
);
```

### 📊 Visual Representation

```
┌───────────────────────────────┐  ← topZoneHeight (default 7 px)
│          Above Zone           │     whenAbove() callback
├───────────────────────────────┤
│                               │
│         Inside Zone           │     whenInside() callback
│                               │
├───────────────────────────────┤  ← targetBounds.height - bottomZoneHeight
│          Below Zone           │     whenBelow() callback
└───────────────────────────────┘  ← bottomZoneHeight (default 5.5 px)
```

Higher `topZoneHeight` / `bottomZoneHeight` values make the upper
and lower bands larger, making "insert as sibling" easier to trigger
vs "insert as child".

### 📑 Method Signature

```dart
P? mapDropPosition<P>({
  required P Function() whenAbove,
  required P Function() whenInside,
  required P Function() whenBelow,
  bool ignoreInsideZone = false,
  bool ignoreAboveZone = false,
  bool ignoreBelowZone = false,
});
```
