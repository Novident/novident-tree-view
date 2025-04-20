## Tree Configuration

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
     buildDragFeedbackWidget: (Node node) => Material(
       type: MaterialType.canvas,
       child: Text(
         '${node.runtimeType} ${node.level}',
       ),
     ),
     preferLongPressDraggable: isMobile,
   ),
);
```
