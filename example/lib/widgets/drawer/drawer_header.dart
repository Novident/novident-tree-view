import 'package:flutter/material.dart';

class TreeViewHeaderTitle extends StatefulWidget {
  const TreeViewHeaderTitle({super.key});

  @override
  State<TreeViewHeaderTitle> createState() => _TreeViewHeaderTitleState();
}

class _TreeViewHeaderTitleState extends State<TreeViewHeaderTitle> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        'Example of Tree View',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.clip,
        maxLines: 1,
        softWrap: true,
      ),
    );
  }
}
