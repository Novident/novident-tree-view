import 'package:example/common/configurations/builders/directory_component_builder.dart';
import 'package:example/common/configurations/builders/file_component_builder.dart';
import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/internal.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

TreeConfiguration treeConfigurationBuilder(
  TreeController controller,
  BuildContext context,
) =>
    TreeConfiguration(
      activateDragAndDropFeature: true,
      addRepaintBoundaries: false,
      components: <NodeComponentBuilder>[
        DirectoryComponentBuilder(),
        FileComponentBuilder(),
      ],
      extraArgs: <String, dynamic>{
        'controller': controller,
      },
      treeListViewConfigurations: ListViewConfigurations(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        addSemanticIndexes: false,
        addAutomaticKeepAlives: false,
      ),
      indentConfiguration: IndentConfiguration.basic(
        indentPerLevel: 14,
        // we need to build a different indentation
        // for files, since folders has a leading
        // button
        indentPerLevelBuilder: (Node node) {
          if (node is File) {
            final double effectiveLeft =
                node.level <= 0 ? 29 : (node.level * 14) + 30;
            return effectiveLeft;
          }
          return null;
        },
      ),
      draggableConfigurations: DraggableConfigurations(
        buildDragFeedbackWidget: (Node node, BuildContext context) {
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
        preferLongPressDraggable: isMobile,
      ),
    );
