import 'package:example/common/configurations/builders/directory_component_builder.dart';
import 'package:example/common/configurations/builders/file_component_builder.dart';
import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: experimental_member_use
import 'package:flutter_quill/internal.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

TreeConfiguration treeConfigurationBuilder(
  TreeController controller,
  BuildContext context,
) =>
    TreeConfiguration(
      builders: <NodeComponentBuilder>[
        DirectoryComponentBuilder(),
        FileComponentBuilder(),
      ],
      sharedData: <String, dynamic>{
        'controller': controller,
      },
      activateDragAndDropFeature: true,
      indentConfiguration: IndentConfiguration.systemFile(
        directoryLeading: false,
        indentation: 20,
      ),
      dragConfig: DraggableConfigurations.simple(
        longPressOnMobile: isMobile,
        expandOnHover: true,
        feedback: (Node node, BuildContext context) {
          return NodeDragCard(
            node: node,
            treeContext: context,
          );
        },
      ),
    );

class NodeDragCard extends StatefulWidget {
  const NodeDragCard({
    super.key,
    required this.node,
    required this.treeContext,
  });
  final Node node;
  final BuildContext treeContext;

  @override
  State<NodeDragCard> createState() => _NodeDragCardState();
}

class _NodeDragCardState extends State<NodeDragCard> {
  @override
  Widget build(BuildContext context) {
    assert(
      widget.treeContext.mounted,
      'context of the tree view should be mounted at this point',
    );
    final DragAndDropDetailsListener listener =
        DragAndDropDetailsListener.of(widget.treeContext);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.node.isFile)
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Icon(
                    widget.node.asFile.content.isEmpty
                        ? CupertinoIcons.doc_text
                        : CupertinoIcons.doc_text_fill,
                    size: isAndroid ? 20 : null,
                  ),
                ),
              if (widget.node.isDirectory)
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  child: Icon(
                    widget.node.asDirectory.isExpanded &&
                            widget.node.asDirectory.isEmpty
                        ? CupertinoIcons.folder_open
                        : CupertinoIcons.folder_fill,
                    size: isAndroid ? 20 : null,
                  ),
                ),
              Center(
                child: Text(
                  widget.node is File
                      ? widget.node.asFile.name
                      : widget.node.asDirectory.name,
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
                  final bool canMove = Node.canMoveTo(
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
  }
}
