import 'package:example/common/configurations/builders/directory_component_builder.dart';
import 'package:example/common/configurations/builders/file_component_builder.dart';
import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/extensions/node_ext.dart';
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
      addRepaintBoundaries: true,
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
      ),
      indentConfiguration: IndentConfiguration.basic(
        indentPerLevel: 10,
        // we need to build a different indentation
        // for files, since folders has a leading
        // button
        indentPerLevelBuilder: (Node node) {
          if (node is File) {
            final double effectiveLeft =
                node.level <= 0 ? 25 : (node.level * 10) + 30;
            return effectiveLeft;
          }
          return null;
        },
      ),
      onHoverContainer: (Node node) {
        if (node is NodeContainer) {
          node.asDirectory.openOrClose(forceOpen: true);
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
        allowAutoExpandOnHover: true,
        preferLongPressDraggable: isMobile,
      ),
    );

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
