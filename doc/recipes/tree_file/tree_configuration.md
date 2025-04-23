## Tree Configuration

In this section, we adds all the builders, and configurations to build a [Tree like this](https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/tree_file.md#tree-file).

```dart
import 'package:your/path/to/builders/directory_component.dart';
import 'package:your/path/to/builders/file_component.dart';

final configs = TreeConfiguration(
   // you can deactivate the drag and drop
   // features here
   activateDragAndDropFeature: true,
   // wrap your widgets into a [RepaintBoundary] widget
   addRepaintBoundaries: true,
   components: <NodeComponentBuilder>[
     DirectoryComponentBuilder(),
     FileComponentBuilder(),
   ],
   // this are arguments that are tracked into the Tree and 
   // it is passed to the [ComponentContext] object.
   extraArgs: <String, dynamic>{},
   treeListViewConfigurations: ListViewConfigurations(
     shrinkWrap: true,
     physics: const NeverScrollableScrollPhysics(),
   ),
   // Here is where we configure the indentation for the Nodes
   // based on the depth level (this property is 
   // used by [AutomaticNodeIndentation])
   indentConfiguration: IndentConfiguration.basic(
     indentPerLevel: 10,
     // at this case we need to build a different indentation
     // for files, since folders has a leading
     // button
     indentPerLevelBuilder: (Node node) {
       if (node is File) {
         final double effectiveLeft =
           node.level <= 0 
           ? 30 
           : (node.level * 10) + 30;
         return effectiveLeft;
       }
       return null;
     },
   ),
   // we you drag a node into a [NodeContainer]
   // after a delay this will be called
   onHoverContainer: (Node node) {
     if (node is NodeContainer) {
       (node as Directory).openOrClose(forceOpen: true);
       return;
     }
   },
   draggableConfigurations: DraggableConfigurations(
     buildDragFeedbackWidget: (Node node, BuildContext context) {
       // This is a listener that the package give to us
       final DragAndDropDetailsListener listener =
           DragAndDropDetailsListener.of(context);
       return Material(
         type: MaterialType.canvas,
         borderRadius: BorderRadius.circular(10),
         clipBehavior: Clip.hardEdge,
         child: Container(
           constraints: BoxConstraints(minWidth: 80, minHeight: 20),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
           ),
           child: Padding(
             padding: const EdgeInsets.all(5),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 if (node.isFile)
                   Padding(
                     padding: const EdgeInsets.only(left: 5, right: 5),
                     child: Icon(
                       node.asFile.content.isEmpty
                           ? CupertinoIcons.doc_text
                           : CupertinoIcons.doc_text_fill,
                       size: isAndroid ? 20 : null,
                      ),
                   ),
                  if (node.isDirectory)
                   Padding(
                     padding: const EdgeInsets.only(left: 5, right: 10),
                     child: Icon(
                        node.asDirectory.isExpanded &&
                               node.asDirectory.isEmpty
                            ? CupertinoIcons.folder_open
                            : CupertinoIcons.folder_fill,
                        size: isAndroid ? 20 : null,
                      ),
                    ),
                  Center(
                    child: Text(
                      node is File ? node.asFile.name : node.asDirectory.name,
                      softWrap: true,
                      maxLines: null,
                    ),
                  ),
                  ValueListenableBuilder<NodeDragAndDropDetails?>(
                    valueListenable: listener.details,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Icon(
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
                      final canMove = Node.canMoveTo(
                        node: value.draggedNode,
                        target: value.targetNode!,
                        inside: value.inside,
                      );
                      if (!canMove) {
                        return child!;
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
     },
     allowAutoExpandOnHover: true,
     preferLongPressDraggable: Platform.isAndroid || Platform.isIOS,
   ),
);
```
