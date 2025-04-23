## Tree File

To have a **Tree** like this:

https://github.com/user-attachments/assets/ce19a72f-65b2-4d02-9226-8f6ebe1895e2

```dart
import 'package:novident_tree_view/novident_tree_view.dart';

final Widget tree = TreeView(
   root: root,
   configuration: config, // see [configs](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_configuration.md)
);

final Directory root = Directory(
  details: NodeDetails.byId(level: -1, id: 'root'),
  name: 'root',
  createAt: DateTime.now(),
  children: [
    Directory(
      details: NodeDetails.zero(),
      name: 'Directory root',
      createAt: DateTime.now(),
      children: [
        Directory(
          children: [
            File(
              details: NodeDetails.withLevel(2),
              name: 'Sub file',
              content: '',
              createAt: DateTime.now(),
            ),
          ],
          details: NodeDetails.withlevel(1),
          name: 'Sub directory',
          createAt: DateTime.now(),
        ),
        File(
          details: NodeDetails.withLevel(1),
          name: 'Sub file',
          content: '',
          createAt: DateTime.now(),
        ),
      ],
    ),
  ],
);
```

You'll need to check some parts and understand them:

### Nodes 

In this section we simply define which nodes will be used by the `TreeView` to display our file tree.

* [**File Node**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/nodes_declaration.md#-file)
* [**Directory Node**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/nodes_declaration.md#-directory)

### Builders

In this section we build the component that will define: the rendering of the nodes, the children rendering (optional), gesture configs, and the **Drag and Drop** feature through `NodeDragGestures`.

* [**File Component Builder**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/builders/file_builder_declaration.md)
* [**Directory Component Builder**](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/builders/directory_builder_declaration.md)

### General configurations

Typically, there isn't much to configure the tree, as most of the work is done through the `NodeComponentBuilder` and the implementations already included in the package. In any case, the most important steps would be:

#### Indentation

The indent configuration used is:

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

![Indent Preview](https://github.com/user-attachments/assets/2f40d4f7-e47f-4bc6-95be-498b842302ab)

#### Visual Drag configurations

The `DraggableConfigurations` used is:

```dart
final configs = DraggableConfigurations(
   buildDragFeedbackWidget: (Node node, BuildContext context) {
     // This is a listener that the package give to us
     final DragAndDropDetailsListener listener =
         DragAndDropDetailsListener.of(context);
     return Material(
       type: MaterialType.canvas,
       borderRadius: BorderRadius.circular(10),
       clipBehavior: Clip.hardEdge,
       child: Container(
         constraints: BoxConstraints(minWidth: 80, minHeight: 20),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(10),
         ),
         child: Padding(
           padding: const EdgeInsets.all(5),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (node.isFile)
                 Padding(
                   padding: const EdgeInsets.only(left: 5, right: 5),
                   child: Icon(
                     node.asFile.content.isEmpty
                         ? CupertinoIcons.doc_text
                         : CupertinoIcons.doc_text_fill,
                     size: isAndroid ? 20 : null,
                    ),
                 ),
                if (node.isDirectory)
                 Padding(
                   padding: const EdgeInsets.only(left: 5, right: 10),
                   child: Icon(
                      node.asDirectory.isExpanded &&
                             node.asDirectory.isEmpty
                          ? CupertinoIcons.folder_open
                          : CupertinoIcons.folder_fill,
                      size: isAndroid ? 20 : null,
                    ),
                  ),
                Center(
                  child: Text(
                    node is File ? node.asFile.name : node.asDirectory.name,
                    softWrap: true,
                    maxLines: null,
                  ),
                ),
                ValueListenableBuilder<NodeDragAndDropDetails?>(
                  valueListenable: listener.details,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                  builder: (
                    BuildContext ctx,
                    NodeDragAndDropDetails? value,
                    Widget? child,
                  ) {
                    if (value == null || value.targetNode == null) {
                      return const SizedBox.shrink();
                    }
                    final canMove = Node.canMoveTo(
                      node: value.draggedNode,
                      target: value.targetNode!,
                      inside: value.inside,
                    );
                    if (!canMove) {
                      return child!;
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      );
   },
   allowAutoExpandOnHover: true,
   preferLongPressDraggable: Platform.isAndroid || Platform.isIOS,
),
```

https://github.com/user-attachments/assets/f19e88d5-e49e-420f-aa2a-18e648402e6b

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

Our result should be like this:

https://github.com/user-attachments/assets/4976240b-db8d-498c-a1df-60158eb0d808

_This is just a code sample, please, check [builders](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/builders/) instead, to create a better implementation._

```dart
@override
NodeDragGestures buildDragGestures(ComponentContext context) {
  final Node node = context.node;
  return NodeDragGestures.standardDragAndDrop(
    onWillInsert: (Node node, NodeContainer newOwner, int newLevel) {
      if(node is File && _selectedNode.value?.id == node.id) {
        _selectedNode.value = node.copyWith(
          details: node.details.copyWith(owner: owner, level: newLevel),
        ),
      }
    }
  );
}
```
