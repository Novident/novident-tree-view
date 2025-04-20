## File Component Builder

In this section we build the component that will define: the gesture configurations, the method in charge of rendering your node, and the **Drag and Drop** feature through `NodeDragGestures`.

```dart
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:your/path/file.dart';

class FileComponentBuilder extends NodeComponentBuilder {
  @override
  Widget build(ComponentContext context) {
    final Node node = context.node;
    Decoration? decoration;
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context.nodeContext).colorScheme.outline,
      width: 2.0,
    );

    if (context.details != null) {
      // Add a border to indicate in which portion of the target's height
      // the dragging node will be inserted.
      final border = context.details?.mapDropPosition<BoxBorder?>(
        whenAbove: () => Border(top: borderSide),
        whenInside: () => const Border(),
        whenBelow: () => Border(bottom: borderSide),
      );
      decoration = BoxDecoration(
        border: border,
        color: border == null ? null : Colors.grey.withValues(alpha: 130),
      );
    }

    return Container(
      decoration: decoration,
      // [AutomaticNodeIndentation] adds the correct indentation
      // for the [Node] using the [IndentConfiguration] passed
      child: AutomaticNodeIndentation(
        node: node,
        child: FileTile(file: node.asFile),
      ),
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    // you need to make your implementation 
    // to know if the node is selected
    final bool isSelected = false; 
    return NodeConfiguration(
      makeTappable: true,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
            : null,
      ),
      onTap: (BuildContext context) {
        // select or focus your node
      },
    );
  }

  @override
  NodeDragGestures buildDragGestures(ComponentContext context) {
    final Node node = context.node;
    return NodeDragGestures(
      onWillAcceptWithDetails: (
        NovDragAndDropDetails<Node>? details,
        DragTargetDetails<Node> dragDetails,
        Node? parent,
      ) => details?.draggedNode != node,
      onAcceptWithDetails: (
        NovDragAndDropDetails<Node> details,
        Node? parent,
      ) {
        final Node target = details.targetNode;
        details.mapDropPosition<void>(
          whenAbove: () {
            final NodeContainer parent = target.owner as NodeContainer;
            final NodeContainer dragParent =
                details.draggedNode.owner as NodeContainer;
            dragParent.removeWhere(
              (n) => n.id == details.draggedNode.id,
            );
            final int index = target.index;
            if (index != -1) {
              parent.insert(
                index,
                details.draggedNode,
                propagateNotifications: true,
              );
            }
          },
          // we not need to define inside, since we don't use it
          whenInside: () {},
          whenBelow: () {
            final NodeContainer parent = target.owner as NodeContainer;
            final NodeContainer dragParent =
                details.draggedNode.owner as NodeContainer;
            dragParent.removeWhere(
              (n) => n.id == details.draggedNode.id,
            );
            final int index = target.index;
            if (index != -1) {
              parent.insert(
                (index + 1).exactByLimit(
                  parent.length,
                ),
                details.draggedNode,
                propagateNotifications: true,
              );
            }
          },
          ignoreInsideZone: true,
        );
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool validate(Node node) => node is File;
}

extension on int {
  int get oneIfZero => this <= 0 ? 1 : this;
  int get zeroIfNegative => this < 0 ? 0 : this;
  int exactByLimit(int limit) => this >= limit ? limit : this;
}
```

### FileTile Widget

```dart
import 'package:your/path/file.dart';
import 'package:flutter/cupertino.dart';

class FileTile extends StatefulWidget {
  final File file;
  const FileTile({
    required this.file,
    super.key,
  });

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              widget.file.content.isEmpty
                  ? CupertinoIcons.doc_text
                  : CupertinoIcons.doc_text_fill,
            ),
          ),
          Expanded(
            child: Text(
              "${widget.file.name}${widget.file.level}",
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
