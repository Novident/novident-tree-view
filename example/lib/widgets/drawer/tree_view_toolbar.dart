import 'package:example/common/controller/tree_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

import '../../common/nodes/directory.dart';
import '../../common/nodes/file.dart';

/// Binder toolbar: new document, new folder and a drop-to-delete trash.
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
  void dispose() {
    isIntoTrash.dispose();
    super.dispose();
  }

  void _addFile() {
    widget.controller.root.add(
      File(
        details: NodeDetails.withLevel(
          0,
          widget.controller.root,
        ),
        content: '',
        name: 'Untitled Document',
        createAt: DateTime.now(),
      ),
    );
  }

  void _addDirectory() {
    widget.controller.root.add(
      Directory(
        details: NodeDetails.withLevel(0, widget.controller.root),
        children: [],
        isExpanded: false,
        name: 'New Folder',
        createAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: <Widget>[
          Tooltip(
            message: 'New document',
            child: IconButton(
              onPressed: _addFile,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(Icons.note_add_outlined),
            ),
          ),
          Tooltip(
            message: 'New folder',
            child: IconButton(
              onPressed: _addDirectory,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(CupertinoIcons.folder_fill_badge_plus),
            ),
          ),
          const Spacer(),
          _buildTrashTarget(),
        ],
      ),
    );
  }

  /// Drop a dragged node here to delete it from the tree.
  Widget _buildTrashTarget() {
    return DragTarget<Node>(
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
            return Tooltip(
              message: 'Drag a node here to delete it',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: value ? Colors.redAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: value ? Colors.white : Colors.grey.shade700,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
