# 🌳 Novident Tree View

<p>
  <img 
    width="1157" 
    height="440"
    alt="Image of Novident Tree View example" 
    src="https://github.com/user-attachments/assets/0e4c91c7-2b6a-490e-9162-116bb022aad3" 
  />
</p>

This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through `Listenable` patterns, enabling reactive updates without complex state management.

## ✨ Highlights

- **No controller required** — nodes extend `Node` / `NodeContainer` directly; the tree reacts to node changes via `Listenable` notifications.
- **Policy‑as‑code builders** — each node type gets its own `NodeComponentBuilder`; the tree picks the first builder whose `validate()` returns `true`.
- **Full drag‑and‑drop by default** — three drop zones per row (above / inside / below), real‑time border feedback, no‑op detection, auto‑expand on hover, Live error badge on the drag card.
- **Scrivener-like example** — complete desktop workspace shipped in `example/` with a binder sidebar, sheet‑of‑paper editor, breadcrumb navigation, and structured content.

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  novident_tree_view: <latest>
  novident_nodes: <latest>
```

## 🚀 Basic usage

```dart
import 'package:novident_tree_view/novident_tree_view.dart';

final Widget tree = TreeView(
  root: myRootContainer,
  configuration: TreeConfiguration(
    builders: [FolderBuilder(), FileBuilder()],
    dragConfig: DraggableConfigurations.simple(
      feedback: (node, ctx) => MyDragCard(node: node),
    ),
    indent: 14,
    sharedData: {'theme': myTheme},
    activateDragAndDropFeature: true,
  ),
);
```

## 🔎 Resources

Since there's a lot to explain and implement, we prefer to provide a separate document for each section.

| Document | Covers |
|---|---|
| [📲 Components](doc/components.md) | How `NodeComponentBuilder` renders nodes, the `ComponentContext` API, the `isDragging` flag, the `validate()` discovery system |
| [🌲 Tree Configuration](doc/tree_configuration.md) | All `TreeConfiguration` properties: `builders`, `dragConfig`, `indent`, `shrinkWrap`, `sharedData`, `listView`, zone heights, etc. |
| [🤏 Draggable Configurations](doc/draggable_configuration.md) | `DraggableConfigurations` — feedback widget, hover expansion, long‑press mode, drag axis, child‑when‑dragging |
| [📏 Indentation Configuration](doc/indentation_configuration.md) | `IndentConfiguration` — static per‑level indentation, dynamic per‑node builders, system‑file presets |
| [📜 Drag and Drop details](doc/drag_and_drop_details.md) | `NovDragAndDropDetails` — drop‑position calculation, three‑zone mapping (`mapDropPosition`), global vs local offset |
| [✍️ Nodes Gestures](doc/nodes_gestures.md) | `NodeDragGestures` — lifecycle callbacks (`onWillAcceptWithDetails`, `onAcceptWithDetails`, `onDragStart`, `onDragCanceled`, …) |
| [🎨 Scrivener‑like Design Guide](doc/design/scrivener-like-design-guide.md) | Complete visual design documentation for the example workspace — colours, typography, spacing, motion, drag visual language, binder architecture, Scrivener design principles applied |

## 📝 Recipes

- [🗃️ Tree File](doc/recipes/tree_file/tree_file.md) — recreate a file tree quickly: node types (`File`, `Directory`, `Root`), builders, configuration, and drag‑and‑drop wiring.

_More recipes will be added later_

## 🌳 Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow.

See [Contributing](https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md) for more details.
