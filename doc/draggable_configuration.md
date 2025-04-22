# 🎨 Draggable configurations  

This is a class that allows us to configure the appearance of the dragged nodes.

It actually contains the parameters required by widgets like Draggable or LongPressDraggable.

## 🎭 Example: Styled Drag Experience  

```dart  
DraggableConfigurations(  
  buildDragFeedbackWidget: (Node node) => Transform.scale(  
    scale: 0.9,  
    child: Opacity(  
      opacity: 0.7,  
      child: node is YourContainer 
        ? YourContainerWidget(node: node) 
        : YourLeafWidget(node: node as YourLeaf),  
  ),  
  childWhenDraggingBuilder: (node) => Placeholder(color: Colors.blue.withValues(alpha: 100)),  
  preferLongPressDraggable: false,  
  axis: Axis.vertical, // Vertical-only dragging  
)  
```  

## 🖼️ Properties  

| Property | Type | Role | Default |  
|----------|------|------|---------|  
| `buildDragFeedbackWidget` | `Widget Function(Node)` | **(Required)** Creates the **ghost widget** following the cursor during drag | - |  
| `childWhenDraggingBuilder` | `Widget Function(Node)?` | Builds the **placeholder** left behind when dragging starts | `null` |  
| `feedbackOffset` | `Offset` | Pixel-perfect positioning of the drag ghost | `Offset.zero` |  
| `childDragAnchorStrategy` | `DragAnchorStrategy` | Alignment logic for the drag ghost's pivot point | local implementation |  

## ⚙️ Interaction Tuners  

| Property | Type | Effect |  
|----------|------|--------|  
| `preferLongPressDraggable` | `bool` | `true` = Mobile-style long-press, `false` = Desktop-style instant drag |  
| `longPressDelay` | `int` | Millisecond delay before recognizing long-press (500ms mobile default) |  
| `axis` | `Axis?` | Constrains drag direction (vertical/horizontal) |  
| `allowAutoExpandOnHover` | `bool` | Enables nodes to auto-unfold when hovered during drag.              |  

```dart  
DraggableConfigurations({  
  required this.buildDragFeedbackWidget, // Mandatory ghost builder  
  this.allowAutoExpandOnHover = true,  
  this.preferLongPressDraggable = false,  
  this.childDragAnchorStrategy = _childDragAnchorStrategy,  
  this.feedbackOffset = Offset.zero,  
  int? longPressDelay, // Auto-sets 500ms if using long-press  
  this.axis, // null = free movement  
  this.childWhenDraggingBuilder, // Optional disappearing act  
})  
```  
