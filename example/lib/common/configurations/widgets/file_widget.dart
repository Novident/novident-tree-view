import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/common/store/document_content_store.dart';
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
  const FileTile({
    required this.file,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          Icon(
            DocumentContentProvider.of(context).hasContent(file.id)
                ? CupertinoIcons.doc_text_fill
                : CupertinoIcons.doc_text,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              file.name,
              style: TextStyle(fontSize: 13),
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
