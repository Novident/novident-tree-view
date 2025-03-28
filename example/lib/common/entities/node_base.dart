import 'package:example/common/entities/node_details.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

abstract class NodeBase extends Node {
  final NodeDetails details;

  NodeBase({
    required this.details,
    super.children,
  });

  NodeBase copyWith({NodeDetails? details});
}
