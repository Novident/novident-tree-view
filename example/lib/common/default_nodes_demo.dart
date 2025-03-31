import 'dart:convert';

import 'package:example/common/contents.dart';
import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:novident_nodes/novident_nodes.dart';

final parentDirNode1 = NodeDetails.withLevel(0);

final List<Node> defaultNodes = [
  Directory(
    details: parentDirNode1,
    name: 'Directory 1',
    createAt: DateTime.now(),
    children: [
      Directory(
        children: [
          File(
            details: NodeDetails.withLevel(2),
            name: 'Sub file 2',
            content: r'[{"insert":"\n"}]',
            createAt: DateTime.now(),
          ),
        ],
        details: NodeDetails(level: 1),
        name: 'Sub directory 1',
        createAt: DateTime.now(),
      ),
      File(
        details: NodeDetails.withLevel(1),
        name: 'Sub file 1',
        content: r'[{"insert":"\n"}]',
        createAt: DateTime.now(),
      ),
    ],
  ),
  Directory(
    details: NodeDetails.withLevel(0),
    name: 'Directory 2',
    createAt: DateTime.now(),
    children: List.from([]),
  ),
  File(
    details: NodeDetails.withLevel(0),
    name: 'Sub file 1.5',
    content: jsonEncode(exampleDelta.toJson()),
    createAt: DateTime.now(),
  ),
];
