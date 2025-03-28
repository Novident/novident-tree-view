# 🌳 Novident Tree View 

This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through `Listenable` patterns, enabling reactive updates without complex state management.

## Motivation 💡

Most existing tree view implementations:

- Require controller setups when probably we don't want to manage the nodes using them
- Force predefined state management strategies
- Limit customization of the internal node behavior

**Novident Tree View solves these by:**

- Using extendable data types instead of enforced controllers
- Letting nodes self-manage their state via `Listenable` (`Node` and `NodeContainer` extends of `ChangeNotifier`)
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
>

### 1. Define a Leaf node 

> [!TIP]
> We call it Leaf because instead of creating nodes that can always have children, we can create Nodes that also only have their own values and don't need to draw any children. You can think of `Node` and `NodeContainer` as the equivalent of `File` and `Directory`.

```dart
class LeafNode extends Node {
  final String title;
  final int nodeLevel;
  final String nodeId;
  NodeContainer? parent;
  
  LeafNode({
    required this.title,
    required this.nodeLevel,
    required this.nodeId,
    this.parent,
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
      dropPosition != DragHandlerPosition.into;

  @override
  bool isDropTarget() {
    return true;
  }

  @override
  String get id => nodeId;

  @override
  int get level => nodeLevel;

  @override
  NodeContainer? get owner => parent;

  @override
  set owner(NodeContainer? owner) {
    parent = owner;
    notifyListeners();
  }
}
```

### 2. Define the Root model

> [!TIP]
> We call it `NodeContainer` because instead of creating nodes that can always have children You can think of `NodeContainer` as the equivalent `Directory`.

```dart
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
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => true;

  // we need to avoid insert unnecessarily
  // the dragged into itself and adding
  // into its parent (when this node is already
  // in it)
  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) => draggedNode.id != id && draggedNode.owner?.id != id;

  @override
  String get id => nodeId;

  @override
  int get level => nodeLevel;

  @override
  NodeContainer? get owner => parent;

  @override
  set owner(NodeContainer? owner) {
    parent = owner;
    notifyListeners();
  }

  @override
  bool get isExpanded => _isExpanded;

  set isExpanded(bool expand) {
    _isExpanded = expand;
    // will rebuild the nodes below this node 
    notifyListeners();
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
    LeafNode(/* ... */),
  ],
);

TreeView(
  root: root,
  configuration: TreeConfiguration(
    nodeBuilder: (node, details) => ListTile(
      title: Text((node as LeafNode).title),
    ),
    // ... other configs
  ),
)
```

## 🌳 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow. These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md) for more details.
