import 'package:example/common/default_configurations/configurations.dart';
import 'package:example/widgets/drawer/drawer_header.dart';
import 'package:example/widgets/drawer/tree_view_toolbar.dart';
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
                    shouldPaintHierarchyLines: true,
                    preferLongPressDraggable: isMobile,
                    buildDragFeedbackWidget: _buildDragFeedback,
                    nodeSectionBuilder: (Node node, DragArgs args) =>
                        _nodeSectionBuilder(node, args, context),
                    leafConfiguration:
                        kDefaultLeafConfiguration(controller, size),
                    containerConfiguration:
                        kDefaultContainerConfiguration(controller, size),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nodeSectionBuilder(Node node, DragArgs object, BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDragFeedback(node) => Material(
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(node is File ? node.name : (node as Directory).name),
        ),
      );
}
