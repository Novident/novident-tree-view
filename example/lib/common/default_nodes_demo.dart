import 'dart:convert';

import 'package:example/common/contents.dart';
import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:novident_nodes/novident_nodes.dart';

final List<Node> defaultNodes = [
  Directory(
    details: NodeDetails.zero(),
    name: 'Directory',
    createAt: DateTime.now(),
    children: [
      Directory(
        children: [
          File(
            details: NodeDetails.withLevel(2),
            name: 'Sub file',
            content: r'[{"insert":"\n"}]',
            createAt: DateTime.now(),
          ),
        ],
        details: NodeDetails(level: 1),
        name: 'Sub directory',
        createAt: DateTime.now(),
      ),
      File(
        details: NodeDetails.withLevel(1),
        name: 'Sub file',
        content: r'[{"insert":"\n"}]',
        createAt: DateTime.now(),
      ),
    ],
  ),
  Directory(
    details: NodeDetails.withLevel(0),
    name: 'Directory',
    createAt: DateTime.now(),
    children: List.from([]),
  ),
  File(
    details: NodeDetails.withLevel(0),
    name: 'Root File',
    content: jsonEncode(exampleDelta.toJson()),
    createAt: DateTime.now(),
  ),
];
