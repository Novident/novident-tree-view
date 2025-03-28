# 🌳 Novident Tree View 

This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through `Listenable` patterns, enabling reactive updates without complex state management.

## Motivation 💡

Most existing tree view implementations:
- Require controller setups when probably we don't want to manage the nodes using them
- Force predefined state management strategies
- Limit customization of the internal node behavior

**Novident Tree View solves these by:**

- Using extendable data types instead of enforced controllers
- Letting nodes self-manage their state via `Listenable`
- Providing gesture hooks instead of predefined behaviors
- Allowing complete visual customization

This approach enables true ownership of your node lifecycle while handling tree-specific rendering logic under the hood.

## Key Features 🚀

- **Hierarchical Structure**: Render nested nodes with configurable indentation
- **Drag-and-Drop**: Full control over drag validation and drop handling
- **Self-Contained Nodes**: Nodes manage their own state via `Listenable`
- **Zero-Controller Architecture**: Optional controller usage (you own the data)
- **Visual Customization**: Complete control over node rendering
- **Keep-Alive Support**: Preserve node states during interactions
- **Edge Cases Handled**: Empty states, boundary conditions, overflow

## Installation 📦

Add to your `pubspec.yaml`:

```yaml
dependencies:
  novident_tree_view: <latest_version>
```

## Basic Usage (Without Drag-and-Drop) 🌱

> [!NOTE]
> Keep in mind that you'll have to manually manage the order and values of the Nodes. For example, to manage the level of the nodes, you'll have to implement your own logic to ensure that each Node has the correct level.

### 1. Define Node Models
```dart
class NodeModel extends Node {
  final String title;
  final int nodeLevel;
  final String nodeId;
  NodeContainer? parent;
  
  NodeModel({
    required this.title,
    required this.nodeLevel,
    required this.nodeId,
    this.parent,
  }));

  @override
  String get id => nodeId;

  @override
  int get level => nodeLevel;

  @override
  NodeContainer? get owner => parent;

  // if is false, this node cannot be dragged 
  // using gestures
  @override
  bool canDrag() {
    return true;
  }

  // if is false, then another nodes
  // cannot be inserted via Drag-and-Drop
  @override
  bool canSiblingsDropInto() {
    return true;
  }
}
// and the container model
class NodeContainerModel extends NodeContainer<Node> {
  final String title;
  final int nodeLevel;
  final String nodeId;
  NodeContainer? parent;
  bool _isExpanded;
  NodeContainerModel({
    required this.title,
    required this.nodeLevel,
    required this.nodeId,
    this.parent,
    bool isExpanded = false,
    super.children,
  }) : _isExpanded = isExpanded;

  @override
  bool get isEmpty => children.isEmpty;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  bool get isExpanded => _isExpanded;

  @override
  String get id => nodeId;

  @override
  int get level => nodeLevel;

  @override
  NodeContainer? get owner => parent;

  // if is false, this node cannot be dragged 
  // using gestures
  @override
  bool canDrag() {
    return true;
  }

  // if is false, then another nodes
  // cannot be inserted via Drag-and-Drop
  @override
  bool canSiblingsDropInto() {
    return true;
  }
}
```

### 2. Build Your Tree
```dart

// you can also create your own root version
// to manage the children by a different way 
// than NodeContainerModel
final root = NodeContainerModel(
  level: 0,
  parent: null,
  children: [
    NodeContainerModel(/* ... */),
    NodeModel(/* ... */),
  ],
);

TreeView(
  root: root,
  configuration: TreeConfiguration(
    nodeBuilder: (node, details) => ListTile(
      title: Text((node as NodeModel).title),
    ),
    // ... other configs
  ),
)
```

## 🌳 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow. These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md) for more details.
