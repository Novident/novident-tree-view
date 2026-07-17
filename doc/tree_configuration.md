# 📐 Tree Configuration

`TreeConfiguration` serves as the centralized configuration hub for all
interactive tree view behaviours and operations.

## 🏗️ Properties

| Property | Type | Required | Default | Notes |
|---|---|---|---|---|
| `builders` | `List<NodeComponentBuilder>` | **yes** | — | At least one; the first builder whose `validate()` returns `true` renders the node. |
| `dragConfig` | `DraggableConfigurations` | no | `DraggableConfigurations(…)` (minimal, no visible feedback) | Drag‑and‑drop configuration including the feedback widget. Use `DraggableConfigurations.simple(feedback: …)` for a quick setup. |
| `activateDragAndDropFeature` | `bool` | no | `true` | Master toggle — when `false`, every node renders as plain content with no `Draggable` / `DragTarget` wrapping. |
| `indent` | `double` | no | `20` | Indentation in logical pixels per tree level. Shorthand; ignored when `indentConfiguration` is provided. |
| `indentConfiguration` | `IndentConfiguration?` | no | `null` | Full indentation control — per‑level static or dynamic via builder. Overrides `indent`. |
| `sharedData` | `Map<String, dynamic>` | no | `{}` | Arbitrary data available to every builder via `ComponentContext.sharedData`. |
| `emptyPlaceholder` | `Widget? Function(BuildContext)?` | no | `null` | Widget shown when the root container has no children. |
| `addRepaintBoundaries` | `bool` | no | `false` | Wrap each row in a `RepaintBoundary`. |
| `shrinkWrap` | `bool` | no | `true` | Whether the tree list should shrink‑wrap. |
| `physics` | `ScrollPhysics` | no | `NeverScrollableScrollPhysics()` | Scroll physics for the tree (overridden by `listView`). |
| `scrollController` | `ScrollController?` | no | `null` | Controller for the tree's main scroll view (overridden by `listView`). |
| `topZoneHeight` | `double` | no | `7` | Height of the top drop zone in logical pixels. |
| `bottomZoneHeight` | `double` | no | `5.5` | Height of the bottom drop zone in logical pixels. |
| `listView` | `ListViewConfigurations?` | no | `null` | Full ListView configuration override — when set, `shrinkWrap`, `physics` and `scrollController` are ignored. |

## 💡 Example Usage

```dart
final config = TreeConfiguration(
  builders: [FolderBuilder(), FileBuilder()],

  // Drag-and-drop
  dragConfig: DraggableConfigurations.simple(
    feedback: (node, context) => DragCard(node: node),
    expandOnHover: true,
  ),
  activateDragAndDropFeature: true,

  // Indentation
  indent: 14,

  // Shared data accessible in every builder via ComponentContext.sharedData
  sharedData: <String, dynamic>{'controller': myController},

  // Scroll
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),

  // Drop zone sensitivity (defaults are fine for most cases)
  topZoneHeight: 7,
  bottomZoneHeight: 5.5,

  // Empty state
  emptyPlaceholder: (context) => const Text('No nodes yet'),
);

final Widget tree = TreeView(
  root: myRootContainer,
  configuration: config,
);
```
