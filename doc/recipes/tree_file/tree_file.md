## Tree Files

To have a Tree like this:

https://github.com/user-attachments/assets/0e24902e-26e9-40bd-bc38-769bda5dec7b

You'll need to check some parts and understand them:

### Nodes 

In this section we simply define which nodes will be used by the `TreeView` to display our file tree.

[Check DragAndDropMixin](https://github.com/Novident/novident-tree-view/blob/master/doc/nodes.md#Drag-and-Drop-capibility)

* [**File Node**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/nodes_declaration.md#-file)
* [**Directory Node**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/nodes_declaration.md#-directory)

### Builders

In this section we build the component that will define: the rendering of the nodes, the children rendering (optional), gesture configs, and the **Drag and Drop** feature through `NodeDragGestures`.

* [**File Component Builder**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/file_builder_declaration.md)
* [**Directory Component Builder**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/directory_builder_declaration.md)

### General configurations

Typically, there isn't much to configure the tree, as most of the work is done through the `NodeComponentBuilder` and the implementations already included in the package. In any case, the most important steps would be:

#### Indentation

[See this](https://github.com/Novident/novident-tree-view/doc/recipes/tree_file/tree_configuration.md)

**Result:** 

![Indent Preview](https://github.com/user-attachments/assets/2f40d4f7-e47f-4bc6-95be-498b842302ab)

The indentation configuration used is:

Code:
```dart
final config = IndentConfiguration.basic(
   indentPerLevel: 10,
   // we need to build a different indentation
   // for files, since folders has a leading
   // button
   indentPerLevelBuilder: (Node node) {
     if (node is File) {
       final double effectiveLeft =
          node.level <= 0 
          ? 25 
          : (node.level * 10) + 30;
       return effectiveLeft;
     }
     return null;
   },
);
```

#### Gestures

To configure a gestures for: press, long press, or secundary press, just override `buildConfigurations()` into your `NodeComponentBuilder` implementation:

```dart
// Assume that you have a notifier to know what's the node selected into the Tree
// 
// This is totally optional and you'll need to create your own implementation
final ValueNotifier<Node?> _selectedNode = ValueNotifier<Node?>(null);

@override
NodeConfiguration buildConfigurations(ComponentContext context) {
  // you need to make your implementation 
  // to know if the node is selected
  final bool isSelected = _selectedNode?.id == context.node.id; 
  return NodeConfiguration(
    makeTappable: true,
    decoration: BoxDecoration(
      color: isSelected 
          ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
          : null,
    ),
    onTap: (BuildContext _) {
      _selectedNode.value = context.node;
    },
  );
}
```


#### Drag configurations

In this case, we'll use basic drag-and-drop configuration. We'll allow nodes to be inserted both above and below their targets, as well as within their targets.

> [!IMPORTANT]
> Keep in mind that it would be best to perform validations to avoid inserting nodes where 
> they're not expected, but this depends on your implementation, so we'll skip that part.

Our result should be and work like this:

https://github.com/user-attachments/assets/f2feea09-bcd1-47aa-bdb7-02ee70558092

_This is just an code sample, please, check [builders](https://github.com/Novident/novident-tree-view/doc/recipes/tree_file/builders/) instead to create a better a more concise configuration._

```dart
@override
NodeDragGestures buildDragGestures(ComponentContext context) {
  final Node node = context.node;
  return NodeDragGestures(
    // make your own validations to know if we can accept
    // that the dragged node can be inserted at any point of this Node
    onWillAcceptWithDetails: (
      NovDragAndDropDetails<Node>? details,
      DragTargetDetails<Node> dragDetails,
      Node? parent,
    ) {
      return details?.draggedNode != node;
    },
    onAcceptWithDetails: (
      NovDragAndDropDetails<Node> details,
      Node? parent,
    ) {
      final Node target = details.targetNode;
      details.mapDropPosition<void>(
         whenAbove: () {
           final NodeContainer parent = target.owner as NodeContainer;
           final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
           final int index = target.index;
           // we need to maintain the _selectedNode updated into the drag events
           _selectedNode.value = details.draggedNode.copyWith(
             details: details.draggedNode.details.copyWith(
               level: target.level,
               owner: parent,
             ),
           );
           if (index != -1) {
             dragParent.moveNode(
               details.draggedNode, 
               parent,
               insertIndex: index, 
               propagate: true,
             );
           }
         },
         whenInside: () {
           final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
           dragParent
             ..removeWhere(
               (n) => n.id == details.draggedNode.id,
               shouldNotify: false,
             )
             ..notify(propagate: true);
           // we need to maintain the _selectedNode updated into the drag events
           _selectedNode.value = details.draggedNode.copyWith(
             details: details.draggedNode.details.copyWith(
               level: target.level + 1,
               owner: target,
             ),
           );
           (targetNode as NodeContainer).add(details.draggedNode, propagateNotifications: true);
         },
         whenBelow: () {
           final NodeContainer parent = target.owner as NodeContainer;
           final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
           final int index = target.index;
           if (index != -1) {
             // we need to maintain the _selectedNode updated into the drag events
             _selectedNode.value = details.draggedNode.copyWith(
               details: details.draggedNode.details.copyWith(
                 level: target.level,
                 owner: target.owner,
               ),
             );
             dragParent.moveNode(
               details.draggedNode, 
               target.owner as NodeContainer,
               insertIndex: (index + 1).exactByLimit(
                 parent.length,
               ), 
               propagate: true,
             );
            }
         },
      );
      return;
    },
  );
}
```
