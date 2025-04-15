import 'package:flutter/material.dart' show BuildContext;
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class ComponentContext {
  final BuildContext nodeContext;
  final int depth;
  final Node node;
  final NovDragAndDropDetails<Node>? details;

  /// These args usually are passed by the user in TreeConfiguration
  final Map<String, dynamic> extraArgs;

  ComponentContext({
    required this.depth,
    required this.nodeContext,
    required this.node,
    required this.details,
    this.extraArgs = const <String, dynamic>{},
  });
}
