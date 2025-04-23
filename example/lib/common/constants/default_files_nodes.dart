import 'dart:convert';

import 'package:example/common/constants/example_delta_content.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:novident_nodes/novident_nodes.dart';

final List<Node> defaultNodes = <Node>[
  Directory(
    details: NodeDetails.zero(),
    name: 'Directory root',
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
    name: 'Directory root 2 -',
    createAt: DateTime.now(),
    children: List.from([
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
    ]),
  ),
  File(
    details: NodeDetails.withLevel(0),
    name: 'Root File',
    content: jsonEncode(exampleDelta.toJson()),
    createAt: DateTime.now(),
  ),
];
