## Tree File

This recipe walks through creating a file‑tree experience using
**Novident Tree View** — directories that expand/collapse, files that
open, and full drag‑and‑drop reorganisation.

### Result

![Tree file example](https://github.com/user-attachments/assets/ce19a72f-65b2-4d02-9226-8f6ebe1895e2)

### Quick setup

```dart
import 'package:novident_tree_view/novident_tree_view.dart';

final Widget tree = TreeView(
  root: root,
  configuration: config,  // see Tree Configuration below
);
```

### Nodes

Define the data types that populate the tree:

- **[File Node](nodes_declaration.md#-file)** — a leaf node with a `name` and `content`.
- **[Directory Node](nodes_declaration.md#-directory)** — a container node that holds children and supports expand/collapse.

### Builders

Each node type needs a `NodeComponentBuilder`:

- **[File Component Builder](builders/file_builder_declaration.md)** — renders the file row, drop‑zone borders, selection highlight and drag gestures.
- **[Directory Component Builder](builders/directory_builder_declaration.md)** — renders the folder row, expand/collapse toggle, and drag gestures.

### Gestures

Configure tap, long‑press and secondary‑tap through
`buildConfigurations()`. For example, a selection highlight:

```dart
@override
NodeConfiguration buildConfigurations(ComponentContext context) {
  final isSelected = selectedNode?.id == context.node.id;
  return NodeConfiguration(
    makeTappable: true,
    decoration: BoxDecoration(
      color: isSelected
          ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
          : null,
    ),
    onTap: (BuildContext _) {
      selectedNode = context.node;
    },
  );
}
```

### Drag configurations

Use `NodeDragGestures.standardDragAndDrop()` — it handles validate,
accept, move, and cancel out of the box.  Add `onWillInsert` to keep
external state (e.g. selection) in sync after a reorder:

```dart
@override
NodeDragGestures buildDragGestures(ComponentContext context) {
  return NodeDragGestures.standardDragAndDrop(
    onWillInsert: (Node node, NodeContainer newOwner, int newLevel) {
      if (node is File && selectedNode?.id == node.id) {
        selectedNode = node.copyWith(
          details: node.details.copyWith(
            owner: newOwner,
            level: newLevel,
          ),
        );
      }
    },
  );
}
```

### Indentation

```dart
final config = IndentConfiguration.basic(
  indentPerLevel: 10,
  indentPerLevelBuilder: (Node node) {
    if (node is File) {
      // Files have no leading chevron — add extra compensation
      final double effectiveLeft =
          node.level <= 0 ? 25 : (node.level * 10) + 30;
      return effectiveLeft;
    }
    return null; // directories use the base indentPerLevel
  },
);
```

### Visual Drag feedback

See the **[Drag feedback card](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/tree_configuration.md)** recipe for the complete `NodeDragCard` implementation with a live error badge.
