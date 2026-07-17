# 🎨 Draggable configurations

`DraggableConfigurations` controls the visual appearance and interaction
behaviour of nodes during drag‑and‑drop operations. It maps directly to
the parameters of Flutter's built‑in `Draggable` / `LongPressDraggable`
widgets.

## ⚡ Quick start

```dart
TreeConfiguration(
  builders: [...],
  dragConfig: DraggableConfigurations.simple(
    feedback: (node, ctx) => DragCard(node: node),
    expandOnHover: true,
    longPressOnMobile: false,
  ),
)
```

`DraggableConfigurations.simple()` is a factory that accepts the three
most commonly tuned settings and leaves the rest at sensible defaults.

## 🖼️ Full constructor

```dart
DraggableConfigurations({
  required Widget Function(Node, BuildContext) buildDragFeedbackWidget,
  bool expandOnHover = true,
  bool preferLongPressDraggable = false,
  EffectiveDragAnchorStrategy childDragAnchorStrategy = _effectiveChildAnchorStrategy,
  Offset feedbackOffset = Offset.zero,
  int? longPressDelay,         // auto 500 ms when preferLongPressDraggable = true
  Axis? axis,                  // null = unconstrained
  Widget Function(Node)? childWhenDraggingBuilder,
})
```

## 📋 Property reference

### Visual

| Property | Type | Required | Default | Notes |
|---|---|---|---|---|
| `buildDragFeedbackWidget` | `Widget Function(Node, BuildContext)` | **yes** | — | The "ghost" widget that follows the pointer during a drag. |
| `childWhenDraggingBuilder` | `Widget Function(Node)?` | no | `null` | Widget shown in place of the original row while it is being dragged. |
| `feedbackOffset` | `Offset` | no | `Offset.zero` | Pixel‑perfect offset applied to the feedback widget relative to the pointer. |
| `childDragAnchorStrategy` | `EffectiveDragAnchorStrategy` | no | internal implementation | Determines where the feedback widget is anchored relative to the child. The default strategy uses the user's cursor offset inside the original widget so the feedback appears to "lift off" from where the pointer was. |

### Interaction

| Property | Type | Default | Notes |
|---|---|---|---|
| `expandOnHover` | `bool` | `true` | Auto‑expand collapsed folders when the pointer hovers over them during a drag. |
| `preferLongPressDraggable` | `bool` | `false` | `true` = use `LongPressDraggable` (mobile‑style), `false` = use `Draggable` (desktop‑style instant drag). |
| `longPressDelay` | `int` | `0` (500 if `preferLongPressDraggable`) | Millisecond delay before a long‑press is recognised. |
| `axis` | `Axis?` | `null` | Constrain drag direction: `Axis.vertical`, `Axis.horizontal`, or `null` for free movement. |

## 🎭 Example: Styled Drag Experience

```dart
DraggableConfigurations(
  buildDragFeedbackWidget: (Node node, BuildContext context) => Transform.scale(
    scale: 0.9,
    child: Opacity(
      opacity: 0.7,
      child: node is YourContainer
        ? YourContainerWidget(node: node)
        : YourLeafWidget(node: node as YourLeaf),
    ),
  ),
  childWhenDraggingBuilder: (node) => const SizedBox.shrink(),
  preferLongPressDraggable: false,
  axis: Axis.vertical,
)
```
