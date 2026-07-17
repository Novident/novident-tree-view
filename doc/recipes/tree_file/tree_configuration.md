## Tree Configuration

Full configuration that ties everything together:

```dart
final TreeConfiguration config = TreeConfiguration(
  activateDragAndDropFeature: true,
  addRepaintBoundaries: true,
  // Builders — order matters; first validate()=true wins
  builders: <NodeComponentBuilder>[
    DirectoryComponentBuilder(),
    FileComponentBuilder(),
  ],
  // Data shared with every builder via ComponentContext.sharedData
  sharedData: <String, dynamic>{},
  // Indentation
  indentConfiguration: IndentConfiguration.basic(
    indentPerLevel: 10,
    indentPerLevelBuilder: (Node node) {
      if (node is File) {
        final double effectiveLeft =
            node.level <= 0 ? 30 : (node.level * 10) + 30;
        return effectiveLeft;
      }
      return null;
    },
  ),
  // Auto-expand folders on hover during drag
  onHoverContainerCallback: (Node node) {
    if (node is NodeContainer) {
      (node as Directory).openOrClose(forceOpen: true);
    }
  },
  // Drag feedback widget + interaction tuning
  dragConfig: DraggableConfigurations(
    buildDragFeedbackWidget: (Node node, BuildContext context) {
      final DragAndDropDetailsListener listener =
          DragAndDropDetailsListener.of(context);
      return Material(
        type: MaterialType.canvas,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.hardEdge,
        child: Container(
          constraints: const BoxConstraints(minWidth: 80, minHeight: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // Centered vertically so icon + text align properly
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (node.isFile)
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Icon(
                      node.asFile.content.isEmpty
                          ? CupertinoIcons.doc_text
                          : CupertinoIcons.doc_text_fill,
                    ),
                  ),
                if (node.isDirectory)
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 10),
                    child: Icon(
                      node.asDirectory.isExpanded
                          ? CupertinoIcons.folder_open
                          : CupertinoIcons.folder_fill,
                    ),
                  ),
                Center(
                  child: Text(
                    node is File ? node.asFile.name : node.asDirectory.name,
                    softWrap: true,
                    maxLines: null,
                  ),
                ),
                // Live error badge — shows red ⊘ when target rejects drop
                ValueListenableBuilder<NodeDragAndDropDetails?>(
                  valueListenable: listener.details,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                  builder: (
                    BuildContext ctx,
                    NodeDragAndDropDetails? value,
                    Widget? child,
                  ) {
                    if (value == null || value.targetNode == null) {
                      return const SizedBox.shrink();
                    }
                    final bool canMove = Node.canMoveTo(
                      node: value.draggedNode,
                      target: value.targetNode!,
                      inside: value.inside,
                    );
                    return canMove ? const SizedBox.shrink() : child!;
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
    expandOnHover: true,
    preferLongPressDraggable: Platform.isAndroid || Platform.isIOS,
  ),
);
```
