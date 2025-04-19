## Tree Files

### Nodes 

### Builders

### General configurations

#### Indentation

[See this](https://github.com/Novident/novident-tree-view/doc/recipes/tree_configuration.md)

The indentation configuration used is:

```dart
final config = IndentConfiguration.basic(
   indentPerLevel: 10,
   // we need to build a different indentation
   // for files, since folders has a leading
   // button
   indentPerLevelBuilder: (Node node) {
     if (node is File) {
       final double effectiveLeft =
          node.level <= 0 
          ? 25 
          : (node.level * 10) + 30;
       return effectiveLeft;
     }
     return null;
   },
);
```

![Indent Preview](https://github.com/user-attachments/assets/2f40d4f7-e47f-4bc6-95be-498b842302ab)

#### Gestures

#### Drag configurations
