# 🌳 Novident Tree View 

This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through `Listenable` patterns, enabling reactive updates without complex state management.

## 💡 Motivation 

We've investigated several alternatives that allow for convenient node tree creation with a standards-compliant implementation. 

However, we couldn't find one. Most of these implementations required initializing a controller or similar to allow for a proper flow of actions within the tree.

However, for **Novident**, this isn't what we're looking for. Our goal is to create a common solution that allows us to:

* Listen for changes to Nodes manually
* Send or force updates to specific Nodes
* Have a common operation flow (insert, delete, move, or update) for nodes within the tree that depends on the user's implementation and not the package (complete control over them)
* Better support for Node configuration

This is why we decided to create this package, which adds everything **Novident** requires in one place. 

In this package, we can simply add a few configurations and leave everything else to it, as our own logic can create a beautiful file/node tree without too much code or the need for drivers.

## 📦 Installation 

Add to your `pubspec.yaml`:

```yaml
dependencies:
  novident_tree_view: <latest_version>
  novident_nodes: <lastest_version>
```


## 🔎 Resources

Since there is too much to explain and implement, we prefer to give to every section a separate document to dedicate correctly explanations about them. 

* [nodes](https://github.com/Novident/novident-tree-view/blob/master/doc/nodes.md)
* [tree_configuration](https://github.com/Novident/novident-tree-view/blob/master/doc/tree_configuration.md)
* [draggable_configurations](https://github.com/Novident/novident-tree-view/blob/master/doc/draggable_configurations.md)
* [nodes_gestures](https://github.com/Novident/novident-tree-view/blob/master/doc/nodes_gestures.md)
* [indentation_configuration](https://github.com/Novident/novident-tree-view/blob/master/doc/indentation_configuration.md)

### Recipes

* [Tree Files](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/)

_More recipes will be here later_

## 🌳 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow. These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md) for more details.
