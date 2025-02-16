import 'package:example/widgets/drawer/drawer_header.dart';
import 'package:example/widgets/drawer/tree_view_toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

import '../../common/entities/directory.dart';
import '../../common/entities/file.dart';

class TreeViewDrawer extends HookWidget {
  final TreeController controller;
  const TreeViewDrawer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    return SafeArea(
      top: true,
      child: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero)),
        width: size.width * 0.95,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                right:
                    BorderSide(color: Colors.black.withOpacity(0.4), width: 1)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TreeViewHeaderTitle(),
                TreeViewToolbar(controller: controller),
                TreeView(
                  controller: controller,
                  configuration: TreeConfiguration(
                    activateDragAndDropFeature: true,
                    paintItemLines: true,
                    useRootSection: true,
                    preferLongPressDraggable: isMobile,
                    buildFeedback: (node) {
                      return Material(
                        surfaceTintColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(node is File
                              ? node.name
                              : (node as Directory).name),
                        ),
                      );
                    },
                    buildSectionBetweenNodes: (node, object) {
                      return Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                    leafConfiguration: LeafConfiguration(
                      onTap: (node, context) {
                        controller.selectNode(node);
                      },
                      boxDecoration: (leaf) => BoxDecoration(
                        color: controller.selection.value?.id == leaf.id
                            ? Colors.black.withOpacity(0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      height: size.height * 0.070,
                      leading: (LeafNode leaf, double indent,
                              BuildContext context) =>
                          Padding(
                        padding: EdgeInsets.only(left: indent, right: 5),
                        child: Icon(
                          (leaf as File).content.isEmpty
                              ? CupertinoIcons.doc_text
                              : CupertinoIcons.doc_text_fill,
                          size: isAndroid ? 20 : null,
                        ),
                      ),
                      content: (LeafNode leaf, indent, context) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              (leaf as File).name,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                      trailing: (LeafNode node, indent, context) {
                        return TrailingMenu(
                          menuChildren: [
                            MenuItemButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                context.readTree().removeAt(node.id);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    containerConfiguration: ContainerConfiguration(
                      showDefaultExpandableButton: false,
                      onDetectDraggingAboveNode: null,
                      onTap: (NodeContainer node, context) {
                        node.openOrClose();
                      },
                      expandableIconConfiguration:
                          ExpandableIconConfiguration.base(),
                      boxDecoration: (container) => BoxDecoration(
                        color: controller.selection.value?.id == container.id
                            ? Colors.black.withOpacity(0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 1.5),
                      height: size.height * 0.070,
                      leading: (NodeContainer node, indent, context) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          node.isExpanded && node.isEmpty
                              ? CupertinoIcons.folder_open
                              : CupertinoIcons.folder_fill,
                          size: isAndroid ? 20 : null,
                        ),
                      ),
                      content: (NodeContainer node, indent, context) =>
                          Expanded(
                        child: Text(
                          (node as Directory).name,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      trailing: (Node node, indent, context) {
                        return TrailingMenu(
                          menuChildren: [
                            MenuItemButton(
                              onPressed: () {
                                context.readTree().insertAt(
                                    File(
                                      details: NodeDetails.zero(node.id),
                                      content: '',
                                      name: 'File',
                                      createAt: DateTime.now(),
                                    ),
                                    node.id,
                                    removeIfNeeded: true);
                                return;
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Add a document'),
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () {
                                context.readTree().insertAt(
                                    Directory(
                                      details: NodeDetails.zero(node.id),
                                      children: List.from([]),
                                      isExpanded: false,
                                      name: 'Directory',
                                      createAt: DateTime.now(),
                                    ),
                                    node.id,
                                    removeIfNeeded: true);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Add a directory'),
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () {
                                context.readTree().removeAt(node.id);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Delete'),
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () {
                                context.readTree().clearNodeChildren(node.id);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Clear children'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrailingMenu extends StatefulWidget {
  final List<MenuItemButton> menuChildren;
  const TrailingMenu({
    super.key,
    required this.menuChildren,
  });

  @override
  State<TrailingMenu> createState() => _TrailingMenuState();
}

class _TrailingMenuState extends State<TrailingMenu> {
  final MenuController controller = MenuController();
  @override
  void dispose() {
    super.dispose();
  }

  void _openOrCloseMenu() {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: controller,
      menuChildren: widget.menuChildren,
      consumeOutsideTap: true,
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: _openOrCloseMenu,
      ),
    );
  }
}
