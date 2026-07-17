## Directory Component Builder

```dart
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class DirectoryComponentBuilder extends NodeComponentBuilder {
  @override
  bool validate(Node node, int depth) => node is Directory;

  @override
  Widget build(ComponentContext context) {
    final Node node = context.node;
    Decoration? decoration;
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context.nodeContext).colorScheme.outline,
      width: 2.0,
    );

    // Drop‑zone feedback
    final NovDragAndDropDetails<Node>? details = context.details;
    if (details != null) {
      BoxBorder? border;
      if (Node.canMoveTo(
        node: details.draggedNode,
        target: details.targetNode,
        inside: details.exactPosition() == DropPosition.inside,
      )) {
        border = details.mapDropPosition<BoxBorder?>(
          whenAbove:  () => Border(top: borderSide),
          whenInside: () => Border.fromBorderSide(borderSide),
          whenBelow:  () => Border(bottom: borderSide),
        );
      }

      decoration = BoxDecoration(
        border: border,
        color: border == null
            ? null
            : Colors.grey.withAlpha(50),
        borderRadius: BorderRadius.circular(5),
      );
    }

    // Dim when being dragged
    if (decoration == null && isDragging) {
      decoration = BoxDecoration(
        color: Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(5),
      );
    }

    return DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      position: DecorationPosition.foreground,
      child: AutomaticNodeIndentation(
        node: node,
        child: DirectoryTile(
          onTap: () => (node as Directory).openOrClose(),
          directory: node as Directory,
          beingDragged: isDragging,
        ),
      ),
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    final Node node = context.node;
    return NodeConfiguration(
      touchable: true,
      onTap: (BuildContext _) {
        (node as Directory).openOrClose();
      },
    );
  }

  @override
  NodeDragGestures buildDragGestures(ComponentContext context) {
    return NodeDragGestures.standardDragAndDrop(
      onWillInsert: (Node node, NodeContainer newOwner, int newLevel) {
        if (node is Directory) {
          node.redepthChildren(currentLevel: newLevel);
        }
      },
    );
  }
}
```

### DirectoryTile Widget

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DirectoryTile extends StatelessWidget {
  final Directory directory;
  final VoidCallback onTap;
  final bool beingDragged;
  const DirectoryTile({
    required this.directory,
    required this.onTap,
    this.beingDragged = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color? mutedColor =
        beingDragged ? Colors.black.withAlpha(150) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
            child: AnimatedRotation(
              turns: directory.isExpanded ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 12,
                color: mutedColor ?? Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            directory.isExpanded
                ? CupertinoIcons.folder_open
                : CupertinoIcons.folder_fill,
            color: mutedColor,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              directory.name,
              style: TextStyle(color: mutedColor),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
```
