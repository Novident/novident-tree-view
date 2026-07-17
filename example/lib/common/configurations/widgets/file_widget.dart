import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/internal.dart';

class FileTile extends StatefulWidget {
  final File file;
  final TreeController controller;
  final bool beingDragged;
  const FileTile({
    required this.file,
    required this.controller,
    this.beingDragged = false,
    super.key,
  });

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  widget.file.content.isEmpty
                      ? CupertinoIcons.doc_text
                      : CupertinoIcons.doc_text_fill,
                  size: 18,
                  color:
                      widget.beingDragged ? Colors.black.withAlpha(150) : null,
                ),
              ),
              Expanded(
                child: Text(
                  widget.file.name,
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
