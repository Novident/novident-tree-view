## Node Component Builder

`NodeComponentBuilder` defines the blueprint for creating customizable node components in tree structures. Implementations control:

- **Visual construction** — the `build()` method returns the widget for a single tree row.
- **Drag‑and‑drop feedback** — the builder receives `NovDragAndDropDetails` via `ComponentContext.details` to draw drop‑zone borders (above / inside / below) and can react to the persistent `isDragging` flag.
- **Interaction configuration** — `buildConfigurations()` returns a `NodeConfiguration` (tap handlers, decoration, InkWell properties). This method is designed to be stateless and static most of the times. For dynamic state reactions, you should manage them inside the `build` method.
- **Drag gesture wiring** — `buildDragGestures()` returns `NodeDragGestures` (standard or custom callbacks).
- **Optional custom children** — override `buildChildren()` to take full control of the subtree layout.

### Component Context

`ComponentContext` provides contextual information and utilities for node construction.

| Property | Type | Description |
|---|---|---|
| `nodeContext` | `BuildContext` | Widget tree context of the current node |
| `depth` | `int` | Node depth in the hierarchy |
| `index` | `int` | Index of the node inside its owner |
| `node` | `Node` | Current node instance |
| `details` | `NovDragAndDropDetails?` | Drag operation details — non‑null only while a dragged node hovers this row as a drop target |
| `isDragging` | `bool` | `true` while this node is the one being dragged (persistent during the whole drag lifecycle, unlike `details`) |
| `sharedData` | `Map<String, dynamic>` | Custom parameters passed via `TreeConfiguration.sharedData` |
| `marksNeedBuild` | `void Function()` | Force‑rebuild the node (call inside gesture handlers when a state change must trigger a repaint) |

### Example implementation

```dart
class CustomComponentBuilder extends NodeComponentBuilder {
  // Node Validation
  @override
  bool validate(Node node, int depth) => node is YourNode;

  /// Required method to avoid using shared builder instance
  CustomComponentBuilder clone(Node node, BuildContext context) => CustomComponentBuilder(); 

  // Visual Construction
  @override
  Widget build(ComponentContext context) {
    // Drop‑zone border: blue = valid, red = invalid
    Decoration? decoration;
    final BorderSide borderSide = BorderSide(
      color: Colors.blueAccent,
      width: 2.0,
    );

    if (context.details != null) {
      final border = context.details?.mapDropPosition<BoxBorder?>(
        whenAbove:  () => Border(top: borderSide),
        whenInside: () => Border.fromBorderSide(borderSide),
        whenBelow:  () => Border(bottom: borderSide),
      );
      decoration = BoxDecoration(
        border: border,
        color: border == null ? null : Colors.blueAccent.withAlpha(50),
        borderRadius: BorderRadius.circular(5),
      );
    }

    // Dim the row while it is being dragged
    if (decoration == null && isDragging) {
      decoration = BoxDecoration(
        color: Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(5),
      );
    }

    return Container( 
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
            : null,
      ),
      child: DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      position: DecorationPosition.foreground,
      child: AutomaticNodeIndentation(
        node: context.node,
        child: YourNodeWidgetRepresentation(
          file: context.node as YourNode,
          beingDragged: isDragging, // dim tile content too
        ),
      ),
    ));
  }

  /// Interaction Configuration
  ///
  /// Never should be added any type of interaction that depends on the
  /// state of any object, since this is only called when the node properties
  /// changes.
  ///
  /// Example of the issue:
  ///
  /// 1. Add a tap interaction
  /// 2. Decoration that takes that tap as "this node is selected"
  /// 3. Tap more nodes than the last one. 
  /// 4. See how the other nodes are not being rebuilded
  ///
  /// For dynamic decoration states, add directly them to the "build" implementation
  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    return NodeConfiguration(
      makeTappable: true,
      onTap: (_) => setState(() => selectNode(context.node)),
    );
  }

  // Drag Gesture Handling
  @override
  NodeDragGestures buildDragGestures(ComponentContext context) {
    return NodeDragGestures.standardDragAndDrop();
  }

  // Custom children rendering (optional)
  @override
  Widget? buildChildren(ComponentContext context) => null;

  /* ── Async rendering (optional) ── */

  /// Return `true` to use the async children pipeline.
  bool get useAsyncBuild => false;

  /// When `true`, [buildChildrenAsync] runs once and the result is
  /// cached; subsequent rebuilds use the standard renderer.
  bool get cacheChildrenAfterFirstAsyncBuild => false;

  /// Async children builder — renders a placeholder while loading,
  /// then replaces it.
  Future<List<Widget>?> buildChildrenAsync(ComponentContext context) async =>
      null;

  /// Placeholder shown while [buildChildrenAsync] is in flight.
  Widget? buildChildrenAsyncPlaceholder(ComponentContext context) => null;

  /// Error widget shown when [buildChildrenAsync] fails.
  Widget? buildChildrenAsyncError(
    ComponentContext context,
    StackTrace? stacktrace,
    Object error,
  ) => null;
}
```

### Dev‑time lifecycle

| Method | When |
|---|---|
| `initState(node, depth)` | First time the builder is assigned to a tree node. |
| `didChangeDependencies(ctx)` | An `InheritedWidget` above the node changed. |
| `didUpdateWidget(ctx, hasListeners)` | The parent widget that wraps this node was updated (e.g. after a tree mutation). |
| `mounted` | Whether the current builder is already mounted in the tree. |
| `setState(callback)` | Same method that mirrors the original `setState` from the Widgets. |
| `dispose(ctx)` | The builder is being removed (node deleted from the tree). |

All four receive a `ComponentContext` so you can interact with the tree
state during the lifecycle event.
