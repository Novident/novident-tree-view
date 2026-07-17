import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/internal.dart';

class DirectoryTile extends StatefulWidget {
  final TreeController controller;
  final Directory directory;
  final VoidCallback onTap;
  final bool beingDragged;
  const DirectoryTile({
    required this.directory,
    required this.controller,
    required this.onTap,
    this.beingDragged = false,
    super.key,
  });

  @override
  State<DirectoryTile> createState() => _DirectoryTileState();
}

class _DirectoryTileState extends State<DirectoryTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  widget.directory.isExpanded && widget.directory.isEmpty
                      ? CupertinoIcons.folder_open
                      : CupertinoIcons.folder_fill,
                  size: 17,
                  color:
                      widget.beingDragged ? Colors.black.withAlpha(150) : null,
                ),
              ),
              Expanded(
                child: Text(
                  widget.directory.name,
                  style: widget.beingDragged
                      ? TextStyle(
                          color: widget.beingDragged
                              ? Colors.black.withAlpha(150)
                              : null,
                        )
                      : null,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
