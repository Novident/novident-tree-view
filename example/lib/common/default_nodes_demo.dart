import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

final subDirNode = Node.withId(1);
final parentDirNode1 = Node.withId(0);

final List<TreeNode> defaultNodes = [
  Directory(
    node: parentDirNode1,
    name: 'Directory 1',
    nodeParent: 'root',
    createAt: DateTime.now(),
    children: [
      Directory(
        nodeParent: 'root',
        children: [
          File(
            node: Node.withId(2),
            name: 'Sub file 2',
            nodeParent: subDirNode.id,
            createAt: DateTime.now(),
          ),
        ],
        node: subDirNode,
        name: 'Sub directory 1',
        createAt: DateTime.now(),
      ),
      File(
        node: Node.withId(1),
        name: 'Sub file 1',
        nodeParent: parentDirNode1.id,
        createAt: DateTime.now(),
      ),
    ],
  ),
  Directory(
    node: Node.withId(0),
    name: 'Directory 2',
    nodeParent: 'root',
    createAt: DateTime.now(),
    children: List.from([]),
  ),
  File(
    node: Node.withId(0),
    name: 'Sub file 1.5',
    nodeParent: 'root',
    createAt: DateTime.now(),
  ),
];
