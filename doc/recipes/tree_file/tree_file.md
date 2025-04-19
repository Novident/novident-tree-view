## Tree Files

### Nodes 

In this section we simply define which nodes will be used by the `TreeView` to display our file tree.

_If you don't know nothing about `DragAndDropMixin` see [DragAndDropMixin](https://github.com/Novident/novident-tree-view/blob/master/doc/nodes.md#Drag-and-Drop-capibility)._

* [🗏 File](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/nodes_declaration.md#-file)
* [ Directory](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/nodes_declaration.md#-directory)

### Builders

In this section we build the component that will define: the gesture configurations, the method in charge of rendering your node, and the **Drag and Drop** feature through `NodeDragGestures`.

* [🗏 File](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/file_builder_declaration.md)
* [ Directory](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/directory_builder_declaration.md)

### General configurations

#### Indentation

[See this](https://github.com/Novident/novident-tree-view/doc/recipes/tree_file/tree_configuration.md)

The indentation configuration used is:

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

#### Gestures

#### Drag configurations
