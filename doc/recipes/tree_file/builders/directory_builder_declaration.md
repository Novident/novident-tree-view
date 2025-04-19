## Directory Component Builder

In this section we build the component that will define: the gesture configurations, the method in charge of rendering your node, and the **Drag and Drop** feature through `NodeDragGestures`.

```dart
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:flutter/material.dart';
import 'package:your/path/directory.dart';

class DirectoryComponentBuilder extends NodeComponentBuilder {
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
        whenInside: () => Border.fromBorderSide(borderSide),
        whenBelow: () => Border(bottom: borderSide),
      );
      decoration = BoxDecoration(
        border: border,
        color: border == null ? null : Colors.blueAccent,
      );
    }

    return Container(
      decoration: decoration,
      // [AutomaticNodeIndentation] adds the correct indentation
      // for the [Node] using the [IndentConfiguration] passed
      child: AutomaticNodeIndentation(
        node: node,
        child: DirectoryTile(
          onTapExpandButton: () {
            (node as Directory).openOrClose();
          },
          directory: node as Directory,
        ),
      ),
    );
  }

  @override
  NodeConfiguration buildConfigurations(ComponentContext context) {
    // you need to make your implementation 
    // to expand the node 
    return NodeConfiguration(
      makeTappable: true,
      onTap: (BuildContext context) {
        // open or close your node
      },
    );
  }

  @override
  NodeDragGestures buildGestures(ComponentContext context) {
    final Node node = context.node;
    return NodeDragGestures(
      onWillAcceptWithDetails: (
        NovDragAndDropDetails<Node>? details,
        DragTargetDetails<Node> dragDetails,
        Node target,
        Node? parent,
      ) {
        return details?.draggedNode != node;
      },
      onAcceptWithDetails: (
        NovDragAndDropDetails<Node>? details,
        Node target,
        Node? parent,
      ) {
        if (details != null) {
          details.mapDropPosition<void>(
            whenAbove: () {
              final NodeContainer parent = target.owner as NodeContainer;
              final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
              final int index = target.index;
              if (index != -1) {
                dragParent.moveNode(
                  details.draggedNode, 
                  parent,
                  insertIndex: index, 
                  propagate: true,
                );
              }
            },
            whenInside: () {
              final NodeContainer dragParent = details.draggedNode.owner as NodeContainer;
              dragParent
                ..removeWhere(
                  (n) => n.id == details.draggedNode.id,
                  shouldNotify: false,
                )
                ..notify(propagate: true);
              (details.targetNode as NodeContainer).add(details.draggedNode, propagateNotifications: true);
            },
            whenBelow: () {
              final int index = target.index;
              if (index != -1) {
                (details.draggedNode.owner as NodeContainer).moveNode(
                  details.draggedNode, 
                  target.owner as NodeContainer,
                  insertIndex: (index + 1).exactByLimit(
                    parent.length,
                  ), 
                  propagate: true,
                );
              }
            },
          );
          return;
        }
      },
    );
  }

  @override
  Widget? buildChildren(ComponentContext context) => null;

  @override
  bool validate(Node node) => node is Directory;
}

extension on int {
  int get oneIfZero => this <= 0 ? 1 : this;
  int get zeroIfNegative => this < 0 ? 0 : this;
  int exactByLimit(int limit) => this >= limit ? limit : this;
}
```

## DirectoryTile Widget

```dart
import 'package:your/path/directory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DirectoryTile extends StatefulWidget {
  final Directory directory;
  final VoidCallback onTapExpandButton;
  const DirectoryTile({
    required this.directory,
    required this.onTapExpandButton,
    super.key,
  });

  @override
  State<DirectoryTile> createState() => _DirectoryTileState();
}

class _DirectoryTileState extends State<DirectoryTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: ListenableBuilder(
        listenable: widget.directory,
        builder: (context, _) {
          return Row(
            children: <Widget>[
              InkWell(
                onTap: widget.onTapExpandButton,
                child: widget.directory.isExpanded
                    ? const Icon(Icons.expand_less)
                    : const Icon(
                        Icons.expand_more,
                      ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  widget.directory.isExpanded && widget.directory.isEmpty
                      ? CupertinoIcons.folder_open
                      : CupertinoIcons.folder_fill,
                ),
              ),
              Expanded(
                child: Text(
                  "${widget.directory.name}${widget.directory.level}",
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```
