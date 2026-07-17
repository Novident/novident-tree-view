import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Project header of the binder, Scrivener style: project icon +
/// project name + demo subtitle.
///
/// Converted from StatefulWidget to StatelessWidget: it held no state.
/// Public API (const constructor) is unchanged.
class TreeViewHeaderTitle extends StatelessWidget {
  const TreeViewHeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: <Widget>[
          Icon(
            CupertinoIcons.book_fill,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'The Hollow Forest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Novident Tree View demo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
