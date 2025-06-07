import 'package:example/common/controller/tree_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

import '../../common/nodes/directory.dart';
import '../../common/nodes/file.dart';

class TreeViewToolbar extends StatefulWidget {
  final TreeController controller;
  const TreeViewToolbar({
    super.key,
    required this.controller,
  });

  @override
  State<TreeViewToolbar> createState() => _TreeViewToolbarState();
}

class _TreeViewToolbarState extends State<TreeViewToolbar> {
  final ValueNotifier<bool> isIntoTrash = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            onPressed: () {
              widget.controller.root.add(
                File(
                  details: NodeDetails.withLevel(
                    0,
                    widget.controller.root,
                  ),
                  content: '',
                  name: 'Basic name',
                  createAt: DateTime.now(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ),
        IconButton(
          onPressed: () {
            widget.controller.root.add(
              Directory(
                details: NodeDetails.withLevel(0, widget.controller.root),
                children: [],
                isExpanded: false,
                name: 'Basic name',
                createAt: DateTime.now(),
              ),
            );
          },
          icon: const Icon(CupertinoIcons.folder_fill_badge_plus),
        ),
        DragTarget<Node>(
          onWillAcceptWithDetails: (details) {
            isIntoTrash.value = widget.controller.root.contains(
              details.data,
            );
            return isIntoTrash.value;
          },
          onAcceptWithDetails: (DragTargetDetails<Node> details) {
            isIntoTrash.value = false;
            bool removed = widget.controller.root.remove(details.data);
            if (!removed) {
              removed = details.data.owner?.remove(details.data) ?? false;
            }

            if (!removed) {
              throw StateError(
                'Node of type '
                '${details.data.runtimeType}'
                ':'
                '${details.data.id.substring(0, 6)} was '
                'not found',
              );
            }
          },
          onLeave: (Node? _) {
            isIntoTrash.value = false;
          },
          builder: (
            BuildContext context,
            List<Node?> candidateData,
            List rejectedData,
          ) {
            return ValueListenableBuilder(
              valueListenable: isIntoTrash,
              builder: (
                BuildContext context,
                bool value,
                Widget? child,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5, top: 5),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: value ? Colors.redAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 22,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
