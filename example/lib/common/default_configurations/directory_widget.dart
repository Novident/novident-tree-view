import 'package:example/common/entities/directory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/internal.dart';

class DirectoryTile extends StatefulWidget {
  final Directory directory;
  const DirectoryTile({
    required this.directory,
    super.key,
  });

  @override
  State<DirectoryTile> createState() => _DirectoryTileState();
}

class _DirectoryTileState extends State<DirectoryTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
    );
  }
}
