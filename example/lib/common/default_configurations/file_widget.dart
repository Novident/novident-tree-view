import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/entities/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/internal.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              "${widget.file.name} ${widget.file.level}",
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
