# 🎨 Visual configuration on Draggable Nodes  

**Designs the visual DNA** of draggable elements in the tree hierarchy. Controls exactly *how* nodes appear and behave during drag operations.  

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

## 🎭 Example: Styled Drag Experience  

```dart  
DraggableConfigurations(  
  buildDragFeedbackWidget: (node) => Transform.scale(  
    scale: 0.9,  
    child: Opacity(  
      opacity: 0.7,  
      child: NodeWidget(node: node),  
  ),  
  childWhenDraggingBuilder: (node) => Placeholder(  
    color: Colors.blue.withValues(alpha: 100),  
  feedbackOffset: const Offset(-20, 10),  
  preferLongPressDraggable: Platform.isAndroid,  
  axis: Axis.vertical, // Vertical-only dragging  
)  
```  
