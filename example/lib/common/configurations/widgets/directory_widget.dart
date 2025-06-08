import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/internal.dart';

class DirectoryTile extends StatefulWidget {
  final TreeController controller;
  final Directory directory;
  final VoidCallback onTap;
  const DirectoryTile({
    required this.directory,
    required this.controller,
    required this.onTap,
    super.key,
  });

  @override
  State<DirectoryTile> createState() => _DirectoryTileState();
}

class _DirectoryTileState extends State<DirectoryTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          OverflowBox(
            fit: OverflowBoxFit.deferToChild,
            child: InkWell(
              onTap: widget.onTap,
              child: widget.directory.isExpanded
                  ? const Icon(Icons.expand_less)
                  : const Icon(
                      Icons.expand_more,
                    ),
            ),
          ),
          const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              widget.directory.isExpanded && widget.directory.isEmpty
                  ? CupertinoIcons.folder_open
                  : CupertinoIcons.folder_fill,
              size: isAndroid ? 20 : null,
            ),
          ),
          Expanded(
            child: Text(
              widget.directory.name,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
