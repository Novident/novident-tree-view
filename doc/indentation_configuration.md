# 🌲 Tree Indentation

**Novident Tree View** provides precise control over indentation
behaviour through two components:

- `IndentConfiguration`: configuration object that defines indentation rules.
- `AutomaticNodeIndentation`: convenience widget that applies the
  indentation based on `node.childrenLevel`.

## 📌 `IndentConfiguration`

| Property | Type | Default | Notes |
|---|---|---|---|
| `indentPerLevel` | `double` | `20` | Base pixels per tree level. |
| `indentPerLevelBuilder` | `double? Function(Node)` | `null` | Dynamic per‑node indentation — overrides `indentPerLevel` when set. |
| `maxLevel` | `int` | unbounded | Nodes deeper than this level receive the same indentation as `maxLevel`. |
| `directoryLeading` | `bool` | `true` | Whether directory items should add their own leading before children. |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.zero` | Additional padding around node rows. |
| `addExtraPaddingFromLevel` | `int` | `0` | Extra indentation applied starting at this depth. |

### Constructors

```dart
// Basic: uniform indentation
IndentConfiguration.basic({
  double indentPerLevel = 20,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  int maxLevel = 999,
});

// Full control
IndentConfiguration({
  double indentPerLevel = 20,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  double? Function(Node)? indentPerLevelBuilder,
  int addExtraPaddingFromLevel = 0,
  int maxLevel = 999,
});

// Pre‑set: system file‑tree style
IndentConfiguration.systemFile({
  bool directoryLeading = false,
  double indentation = 20,
  int maxLevel = 999,
  int addExtraPaddingFromLevel = 0,
});
```

## 🧷 `AutomaticNodeIndentation` Example

```dart
AutomaticNodeIndentation(
  node: myNode,
  child: myNodeWidget(),
)
```

The widget reads the current `IndentConfiguration` from the tree
context and applies `node.childrenLevel * indentPerLevel` as leading
padding.  No additional configuration is needed inside the builder.
