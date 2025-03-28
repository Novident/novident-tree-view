import 'package:example/common/entities/directory.dart';
import 'package:example/common/entities/file.dart';
import 'package:example/common/entities/node_base.dart';
import 'package:example/common/entities/root.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

extension NodeExt on Node {
  bool get isContainer => isChildrenContainer;
  bool get isLeaf => !isChildrenContainer;
  bool get isFile => this is File;
  bool get isDirectory => this is Directory;
  bool get isRoot => this is Root;

  NodeBase get asBase => this as NodeBase;
  Directory get asDirectory => this as Directory;
  File get asFile => this as File;
}
