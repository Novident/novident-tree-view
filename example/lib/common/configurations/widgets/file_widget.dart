import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Binder row for a [File]: document icon + name.
///
/// The leading 16px gap aligns file names with directory names
/// (chevron 12px + 4px gap in `DirectoryTile`).
///
/// Converted from StatefulWidget to StatelessWidget: it held no state.
/// Public API (constructor) is unchanged.
class FileTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // While dragged, every element of the row is muted to the same tone.
    final Color? mutedColor =
        beingDragged ? Colors.black.withAlpha(150) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          Icon(
            file.content.isEmpty
                ? CupertinoIcons.doc_text
                : CupertinoIcons.doc_text_fill,
            size: 16,
            color: mutedColor ?? Colors.blueGrey.shade400,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              file.name,
              style: TextStyle(
                fontSize: 13,
                color: mutedColor,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
