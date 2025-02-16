import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

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
                  details:
                      NodeDetails.withLevel(null, widget.controller.root.id),
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
                details: NodeDetails.withLevel(null, widget.controller.root.id),
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
