# 🌲 Tree Indentation

**Novident Tree View** provides precise control over indentation behavior in tree structures through two main components:

- `IndentConfiguration`: Configures indentation rules
- `AutomaticNodeIndentation`: Widget that applies indentation based on node depth

## 📌 `IndentConfiguration`

Defines indentation rules for tree nodes with configurable:

- Base indentation per level
- Maximum indentation depth
- Dynamic indentation rules using `indentPerLevelBuilder`
- Additional node padding

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `indentPerLevel` | `double` | Base pixels to indent per tree level (default: 20px) |
| `indentPerLevelBuilder` | `double? Function(Node)` | Dynamic indentation calculator (optional) |
| `maxLevel` | `int` | Maximum level to indent (default: unlimited) |
| `padding` | `EdgeInsetsGeometry` | Additional padding around nodes (default: zero) |

### Constructor

```dart
IndentConfiguration({
  this.indentPerLevel = 20,
  this.padding = EdgeInsets.zero,
  this.indentPerLevelBuilder,
  this.maxLevel = largestIndentAccepted,
});
```

Now, keep in mind that this configuration will be used and passed throughout the entire Tree, but how can we apply this indentation to our Nodes? Well, for this, there's `AutomaticNodeIndentation`, which, as its name suggests, only needs a few properties to properly indent your widgets (it internally obtains `IndentConfiguration`).

## 🧷 `AutomaticNodeIndentation` Example

```dart
final Widget child = AutomaticNodeIndentation(
  node: myNode,
  child: myNodeWidget(),
);
```
