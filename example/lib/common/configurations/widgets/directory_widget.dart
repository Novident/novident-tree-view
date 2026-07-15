import 'dart:math';

import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:flutter/cupertino.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
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
          Row(
            spacing: 5,
            children: [
              Text('Owner: ${widget.directory.owner?.id.substring(
                0,
                min(4, widget.directory.owner?.id.length ?? 0),
              )}'),
              Text('ID: ${widget.directory.id.substring(0, 4)}'),
            ],
          ),
        ],
      ),
    );
  }
}
