## ⛓️‍💥 Nodes declaration

### 📄 File

As we know, a `File` is simply a type of file that has `content`, a `name` (you can add the rest yourself), and a `creation date`. It doesn't accept any type of `File`/`Node` insertion within it.

_In this example we skip the definition of the NodeVisitor methods, since we want to make the example short and direct._

A way to represent something similar for **Novident Tree View**:

```dart
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_nodes/novident_nodes.dart';

class File extends Node implements DragAndDropMixin {
  final String name;
  final String content;
  final DateTime createAt;

  File({
    required super.details,
    required this.content,
    required this.name,
    required this.createAt,
  });

  /// Determine if the Node can be dragged
  @override
  bool isDraggable() => true;

  /// Determine if this Node allows dropping other nodes into itself
  @override
  bool isDropIntoAllowed() => false;

  /// Determine if the position to the drop is valid 
  @override
  bool isDropPositionValid(
    Node draggedNode,
    DragHandlerPosition dropPosition,
  ) =>
      dropPosition == DragHandlerPosition.above ||
      dropPosition == DragHandlerPosition.below;

  /// Determine if this Node allows dropping other nodes into/above/below it 
  @override
  bool isDropTarget() => true;

  // ... rest of these methods are the common used

  @override
  File copyWith({
    NodeDetails? details,
    String? name,
    DateTime? createAt,
    String? content,
  }) {
    return File(
      details: details ?? this.details,
      content: content ?? this.content,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  File clone() {
    return File(
      details: details,
      content: content,
      name: name,
      createAt: createAt,
    );
  }

  @override
  File cloneWithNewLevel(int level) {
    return copyWith(
      details: details.cloneWithNewLevel(level),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'details': details.toJson(),
      'content': content,
      'createAt': createAt.millisecondsSinceEpoch,
    };
  }

  // ... rest of the needed methods related with [NodeVisitor] mixin

  @override
  bool operator ==(Object other) {
    if (other is! File) {
      return false;
    }
    if(identical(this, other)) return true;
    return details == other.details &&
        content == other.content &&
        name == other.name &&
        createAt == other.createAt;
  }

  @override
  int get hashCode =>
      details.hashCode ^
      createAt.hashCode ^
      name.hashCode ^
      content.hashCode;
}
```

### 📂 Directory

As we know, a `Directory` is just a type of file that has a `name` (you can add the rest yourself), a `creation date`, and can contain `children`.

_If you're wondering why we didn't add a comment here about skipping the definition of the `NodeVisitor` methods, it's because, by default, `NodeContainer` already defines these methods, which saves us from having to create them ourselves._

```dart
import 'package:flutter/foundation.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class Directory extends NodeContainer implements DragAndDropMixin {
  final String name;
  final DateTime createAt;
  bool _isExpanded;

  Directory({
    required super.details,
    required super.children,
    required this.name,
    required this.createAt,
    bool isExpanded = false,
  }) : _isExpanded = isExpanded {
    // you'll need to manually set the owner property
    // to the children passed to avoid unexpected issues
    for (final Node child in children) {
      if (child.owner != this) {
        child.owner = this;
      }
    }
    // this is an optional method
    // we use it to ensure that we are
    // having the correct depth level 
    // for the node children passed
    redepthChildren();
  }

  @override
  bool get isExpanded => _isExpanded;

  void openOrClose({bool forceOpen = false}) {
    _isExpanded = forceOpen ? true : !isExpanded;
    notifyListeners();
  }

  /// adjust the depth level of the children
  void redepthChildren({int? currentLevel}) {
    void redepth(List<Node> unformattedChildren, int currentLevel) {
      for (int i = 0; i < unformattedChildren.length; i++) {
        final Node node = unformattedChildren.elementAt(i);
        unformattedChildren[i] = node.cloneWithNewLevel(currentLevel + 1);
        if (node is NodeContainer && node.isNotEmpty) {
          redepth(node.children, currentLevel + 1);
        }
      }
    }

    redepth(children, currentLevel ?? level);
    notifyListeners();
  }

  set isExpanded(bool expand) {
    _isExpanded = expand;
    notifyListeners();
  }

  // for directories, as we know, we can drag and drop at any point 
  // that we want
  @override
  bool isDraggable() => true;

  @override
  bool isDropIntoAllowed() => true;

  @override
  bool isDropTarget() => true;

  @override
  bool isDropPositionValid(
    Node draggedNode, 
    DragHandlerPosition dropPosition,
  ) => true;

  @override
  Directory copyWith({
    NodeDetails? details,
    List<Node>? children,
    bool? isExpanded,
    String? name,
    DateTime? createAt,
  }) {
    return Directory(
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      details: details ?? this.details,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  String toString() {
    return 'Directory('
        'name: $name, '
        'isExpanded: $isExpanded, '
        'count nodes: ${children.length}, '
        'depth: $level'
        ')';
  }

  @override
  Directory clone() {
    return Directory(
      children: children,
      details: details,
      isExpanded: _isExpanded,
      name: name,
      createAt: createAt,
    );
  }

  @override
  Directory cloneWithNewLevel(int level) {
    return copyWith(
      details: details.cloneWithNewLevel(
        level,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'details': details.toJson(),
      'createAt': createAt.millisecondsSinceEpoch,
      'name': name,
      'children': children.map((Node e) => e.toJson()).toList(),
      'isExpanded': _isExpanded,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! Directory) {
      return false;
    }
    if (identical(this, other)) return true;
    return listEquals(children, other.children) &&
        name == other.name &&
        details == other.details &&
        createAt == other.createAt &&
        _isExpanded == other._isExpanded;
  }

  @override
  int get hashCode =>
      details.hashCode ^
      createAt.hashCode ^
      name.hashCode ^
      children.hashCode ^
      _isExpanded.hashCode;
}
```
