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
    return Container(
      decoration: _buildDropIndicator(context),
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
    return NodeDragGestures(
      onWillAcceptWithDetails: (details, dragDetails, parent) => /* ... your implementation */,
      onAcceptWithDetails: (details, parent) => /* ...your implementation */,
    );
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
