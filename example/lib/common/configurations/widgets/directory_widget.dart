import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Scrivener-like folder blue.
const Color _kFolderBlue = Color(0xFF6FA8DC);

/// Binder row for a [Directory]: animated disclosure chevron + folder
/// icon + name + (collapsed only) children count.
///
/// Converted from StatefulWidget to StatelessWidget: it held no state.
/// Public API (constructor) is unchanged.
class DirectoryTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // While dragged, every element of the row is muted to the same tone.
    final Color? mutedColor = beingDragged ? Colors.black.withAlpha(150) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: Row(
        children: <Widget>[
          AnimatedRotation(
            turns: directory.isExpanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Icon(
              CupertinoIcons.chevron_right,
              size: 12,
              color: mutedColor ?? Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            directory.isExpanded
                ? CupertinoIcons.folder_open
                : CupertinoIcons.folder_fill,
            size: 17,
            color: mutedColor ?? _kFolderBlue,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              directory.name,
              style: TextStyle(
                fontSize: 13,
                color: mutedColor,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
          if (!directory.isExpanded && directory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 2),
              child: Text(
                '${directory.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
