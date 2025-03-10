import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

LeafConfiguration kDefaultLeafConfiguration(
  TreeController controller,
  Size size,
) =>
    LeafConfiguration(
      onTap: (Node node, BuildContext context) {
        controller.selectNode(node);
      },
      boxDecoration: (LeafNode leaf) => BoxDecoration(
        color: controller.selection.value?.id == leaf.id
            ? Colors.black.withOpacity(0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: size.height * 0.070,
      leading: (LeafNode leaf, double indent, BuildContext context) => Padding(
        padding: EdgeInsets.only(left: indent, right: 5),
        child: Icon(
          (leaf as File).content.isEmpty
              ? CupertinoIcons.doc_text
              : CupertinoIcons.doc_text_fill,
          size: isAndroid ? 20 : null,
        ),
      ),
      content: (LeafNode leaf, double indent, BuildContext context) {
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
      trailing: (LeafNode node, double indent, BuildContext context) {
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
    );

ContainerConfiguration kDefaultContainerConfiguration(
    TreeController controller, Size size) {
  return ContainerConfiguration(
    showDefaultExpandableButton: false,
    onTap: (NodeContainer node, BuildContext context) {
      node.openOrClose();
    },
    expandableIconConfiguration: const ExpandableIconConfiguration.base(),
    boxDecoration: (NodeContainer<Node> container) => BoxDecoration(
      color: controller.selection.value?.id == container.id
          ? Colors.black.withOpacity(0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
    height: size.height * 0.070,
    leading: (NodeContainer node, double indent, BuildContext context) =>
        Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Icon(
        node.isExpanded && node.isEmpty
            ? CupertinoIcons.folder_open
            : CupertinoIcons.folder_fill,
        size: isAndroid ? 20 : null,
      ),
    ),
    content: (NodeContainer node, double indent, BuildContext context) =>
        Expanded(
      child: Text(
        (node as Directory).name,
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.fade,
      ),
    ),
    trailing: (Node node, double indent, BuildContext context) {
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
  );
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
