import 'package:example/common/controller/tree_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

import '../../common/entities/directory.dart';
import '../../common/entities/file.dart';

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
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            onPressed: () {
              widget.controller.insertAtRoot(
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
            widget.controller.insertAtRoot(
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
      ],
    );
  }
}
