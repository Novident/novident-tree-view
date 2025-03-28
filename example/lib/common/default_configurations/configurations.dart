import 'package:example/common/default_configurations/directory_widget.dart';
import 'package:example/common/default_configurations/file_widget.dart';
import 'package:example/common/extensions/node_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/internal.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

TreeConfiguration treeConfigurationBuilder(
  BuildContext context,
) =>
    TreeConfiguration(
      keepAliveTree: true,
      activateDragAndDropFeature: true,
      indentConfiguration: IndentConfiguration(),
      scrollConfigs: ScrollConfigs(),
      onHoverContainer: (NodeContainer<Node> node) {},
      draggableConfigurations: DraggableConfigurations(
          buildDragFeedbackWidget: (node) => const Material(),
          childDragAnchorStrategy: (
            Draggable<Object> draggable,
            BuildContext context,
            Offset position,
          ) {
            final RenderBox renderObject = context.findRenderObject()! as RenderBox;
            return renderObject.globalToLocal(position);
          },
          allowAutoExpandOnHover: true,
          preferLongPressDraggable: isMobile),
      nodeDragGestures: (Node node) {
        return NodeDragGestures(
          onWillAcceptWithDetails: (
            NovDragAndDropDetails<Node>? details,
            DragTargetDetails<Node> dragDetails,
            NodeContainer<Node>? parent,
          ) =>
              false,
          onAcceptWithDetails: (
            NovDragAndDropDetails<Node>? details,
            NodeContainer<Node>? parent,
            DragHandlerPosition position,
          ) {},
        );
      },
      nodeBuilder: (Node node, NovDragAndDropDetails<Node>? details) {
        Decoration? decoration;
        final BorderSide borderSide = BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 2.0,
        );

        if (details != null) {
          // Add a border to indicate in which portion of the target's height
          // the dragging node will be inserted.
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () => Border(top: borderSide),
              whenInside: () => Border.fromBorderSide(borderSide),
              whenBelow: () => Border(bottom: borderSide),
            ),
          );
        }
        if(node.isRoot) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: decoration,
          child: node.isDirectory
              ? DirectoryTile(directory: node.asDirectory)
              : FileTile(file: node.asFile),
        );
      },
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
