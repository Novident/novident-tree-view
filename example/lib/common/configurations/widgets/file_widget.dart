import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/internal.dart';
import 'package:novident_nodes/novident_nodes.dart';

class FileTile extends StatefulWidget {
  final File file;
  final TreeController controller;
  const FileTile({
    required this.file,
    required this.controller,
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
                  size: isAndroid ? 20 : null,
                ),
              ),
              Expanded(
                child: Text(
                  widget.file.name,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Text('ID: ${widget.file.id.substring(0, 4)}'),
              Text(
                'OWID: ${widget.file.owner?.id.substring(0, 4) ?? 'N/A'}',
              ),
              Text(
                'L: ${widget.file.childrenLevel}',
              ),
              if (widget.file.nextSibling != null)
                Text(
                  'M: ${Node.canMoveTo(
                    node: widget.file,
                    target: widget.file.nextSibling!,
                    inside: true,
                  )!.toString()}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
