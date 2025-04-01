# 🌳 Novident Tree View 

This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through `Listenable` patterns, enabling reactive updates without complex state management.

## Motivation 💡

**Novident Tree View solves these by:**

- Using extendable data types instead of enforced controllers
- Letting nodes self-manage their state via `Listenable` (`Node` extend of `ChangeNotifier`)
- Providing gesture hooks instead of predefined behaviors
- Allowing complete visual customization

This approach enables true ownership of your node lifecycle while handling tree-specific rendering logic under the hood.

## Installation 📦

Add to your `pubspec.yaml`:

```yaml
dependencies:
  novident_tree_view: <latest_version>
  novident_nodes: <lastest_version>
```

## Example 🌱

> [!NOTE]
> Keep in mind that you'll have to manually manage the order and values of the Nodes. For example, to manage the level of the nodes, you'll have to implement your own logic to ensure that each Node has the correct level.
>

### 1. Define a Leaf node 

> [!TIP]
> You can think on this version of a `Node` as the equivalent of `File`.

```dart
import 'package:novident_tree_view/novident_tree_view.dart';

class LeafNode extends Node implements DragAndDropMixin {
  final String title;
  
  LeafNode({
    required this.title,
    required super.details,
  }));

  @override
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => false;

  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) =>
      dropPosition == DragHandlerPosition.above ||
      dropPosition == DragHandlerPosition.below;

  @override
  bool isDropTarget() => true;
}
```

### 2. Define the Container model

> [!TIP]
> You can think in this version of the `NodeContainer` as the equivalent `Directory`.

```dart
import 'package:novident_tree_view/novident_tree_view.dart';

class Container extends NodeContainer implements DragAndDropMixin {
  final String title;
  bool _isExpanded;

  Container({
    required this.title,
    bool isExpanded = false,
    super.parent,
    super.children,
  }) : _isExpanded = isExpanded;

  @override
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => true;

  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) =>
      draggedNode.id != id && draggedNode.owner?.id != id;

  @override
  bool isDropTarget() {
    return true;
  }

  // if the node has children and is expanded
  // this ensure to show them
  @override
  bool get isExpanded => _isExpanded;
}
```

### 2. Build Your Tree

```dart
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:flutter/material.dart';

// you can also create your own root version
// to manage the children by a different way 
// than NodeContainer
//
// See https://github.com/Novident/novident-tree-view/blob/master/example/lib/common/entities/root.dart
final root = Container(
  details: NodeDetails(level -1),
  children: [
    Container(/* ... */),
    LeafNode(/* ... */),
  ],
);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree view example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TreeView(
              root: root,
              configuration: TreeConfiguration(
                // ...your configs
                // if you need an example of 
                // how configurate the tree
                // check this example config
                //
                // https://github.com/Novident/novident-tree-view/blob/master/example/lib/common/default_configurations/configurations.dart
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🌳 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow. These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md) for more details.
