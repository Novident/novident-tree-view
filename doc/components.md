## Node Component Builder

`NodeComponentBuilder` defines the blueprint for creating customizable node components in tree structures. Implementations control:

### Example implementation 

```dart
class CustomComponentBuilder extends NodeComponentBuilder {
  // Node Validation
  @override
  bool validate(Node node) => node is YourNode;

  // Visual Construction
  @override
  Widget build(ComponentContext context) {
    // you can add a visual border to represent
    // where will be inserted your node
    Decoration? decoration;
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context.nodeContext).colorScheme.outline,
      width: 2.0,
    );

    if (context.details != null) {
      // Add a border to indicate in which portion of the target's height
      // the dragging node will be inserted.
      final border = context.details?.mapDropPosition<BoxBorder?>(
        whenAbove: () => Border(top: borderSide),
        whenInside: () => const Border(),
        whenBelow: () => Border(bottom: borderSide),
      );
      decoration = BoxDecoration(
        border: border,
        color: border == null ? null : Colors.grey.withValues(alpha: 130),
      );
    }
    return DecoratedBox(
      decoration: decoration ?? BoxDecoration(),
      position: DecorationPosition.foreground,
      child: AutomaticNodeIndentation(
        child: YourNodeWidgetRepresentation(
          file: context.node as YourNode,
        ),
      ),
    );
  }

  // Custom children rendering
  //
  // Tip: you can use [wrapWithDragGestures] method into [ComponentContext] 
  //  to add drag interactions automatically to your custom children
  @override
  Widget? buildChildren(ComponentContext context) => null;

  // Interaction Configuration
  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    return NodeConfiguration(
      makeTappable: true,
      decoration: _buildSelectionHighlight(context),
      onTap: _handleNodeSelection,
    );
  }

  // Drag Gesture Handling
  @override
  NodeDragGestures buildDragGestures(ComponentContext context) {
    return NodeDragGestures.standardDragAndDrop();
  }
}
```

## Component Context

`ComponentContext` provides contextual information and utilities for node construction.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `nodeContext` | `BuildContext` | Widget tree context |
| `depth` | `int` | Node depth in hierarchy |
| `node` | `Node` | Current node instance |
| `details` | `NovDragAndDropDetails?` | Drag operation details |
| `wrapWithDragGestures` | `Function` | custom Drag gesture wrapper (for custom children) |
| `extraArgs` | `Map<String,dynamic>` | Custom parameters |
