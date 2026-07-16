import 'dart:convert';

import 'package:example/common/constants/example_delta_content.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:novident_nodes/novident_nodes.dart';

final List<Node> defaultNodes = <Node>[
  Directory(
    details: NodeDetails.zero(),
    name: 'Manuscript',
    createAt: DateTime.now(),
    children: [
      Directory(
        children: [
          File(
            details: NodeDetails.withLevel(2),
            name: 'Dark Woords',
            content: r'[{"insert":"\n"}]',
            createAt: DateTime.now(),
          ),
        ],
        details: NodeDetails(level: 1),
        name: 'Chapter 1',
        createAt: DateTime.now(),
      ),
      Directory(
        children: [
          File(
            details: NodeDetails.withLevel(2),
            name: 'Tabern',
            content: r'[{"insert":"\n"}]',
            createAt: DateTime.now(),
          ),
        ],
        details: NodeDetails(level: 1),
        name: 'Chapter 2',
        createAt: DateTime.now(),
      ),
    ],
  ),
  Directory(
    details: NodeDetails.withLevel(0),
    name: 'Research',
    createAt: DateTime.now(),
    children: List.from([
      File(
        details: NodeDetails.withLevel(0),
        name: 'Root File',
        content: jsonEncode(exampleDelta.toJson()),
        createAt: DateTime.now(),
      ),
    ]),
  ),
];
