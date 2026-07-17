## File Component Builder

```dart
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class FileComponentBuilder extends NodeComponentBuilder {
  @override
  bool validate(Node node, int depth) => node is File;

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
        child: FileTile(
          file: node.asFile,
          beingDragged: isDragging,
        ),
      ),
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    final bool isSelected = false; // your selection logic
    return NodeConfiguration(
      touchable: true,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
            : null,
      ),
      onTap: (BuildContext _) {
        // select or focus your node
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

### FileTile Widget

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FileTile extends StatelessWidget {
  final File file;
  final bool beingDragged;
  const FileTile({
    required this.file,
    this.beingDragged = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color? mutedColor =
        beingDragged ? Colors.black.withAlpha(150) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              file.content.isEmpty
                  ? CupertinoIcons.doc_text
                  : CupertinoIcons.doc_text_fill,
              color: mutedColor,
            ),
          ),
          Expanded(
            child: Text(
              file.name,
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
