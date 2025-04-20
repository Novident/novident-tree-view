# 📐 `TreeConfiguration` - Centralized Tree Behavior Configuration

Immutable class that serves as the centralized configuration hub for all interactive tree view behaviors and operations.

## 🏗️ Core Structure

### 🔧 Configurable Properties

| Property | Type | Description | Default Value |
|----------|------|-------------|---------------|
| `components` | `List<NodeComponentBuilder>` | **(Required)** Component builders for node rendering | - |
| `treeListViewConfigurations` | `ListViewConfigurations` | Underlying ListView configuration | `const ListViewConfigurations()` |
| `extraArgs` | `Map<String, dynamic>` | Shared arguments for node builders | `const <String, dynamic>{}` |
| `addRepaintBoundaries` | `bool` | Whether to wrap rows in RepaintBoundary | `false` |
| `onHoverContainer` | `Function(NodeContainer)` | Container hover callback | `null` |
| `draggableConfigurations` | `DraggableConfigurations` | **(Required)** Drag-and-drop settings | - |
| `activateDragAndDropFeature` | `bool` | Master toggle for DnD functionality | `true` |
| `onDetectEmptyRoot` | `Widget?` | Empty root state widget | `null` |
| `onHoverContainerExpansionDelay` | `int` | Auto-expansion delay on hover (ms) | `625` |
| `indentConfiguration` | `IndentConfiguration` | Indentation styling | `IndentConfiguration.basic()` |

## � Example Usage
```dart
TreeConfiguration(
  components: [MyNodeBuilder(), AnotherNodeBuilder()],
  draggableConfigurations: DraggableConfigurations(...),
  indentConfiguration: IndentConfiguration.basic(...),
  onHoverContainer: (node) => debugPrint('Hovering: ${node.details.id}'),
  activateDragAndDropFeature: !kIsWeb, // Disable on web
);
```
