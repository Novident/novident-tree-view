import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:provider/provider.dart';

Widget wrapWithDragAndDropWidgets(
  ComponentContext context,
  NodeComponentBuilder builder,
  Widget child,
  bool wrapWithListenableBuilder,
) {
  final Node node = context.node;
  final TreeConfiguration configuration =
      Provider.of<TreeConfiguration>(context.nodeContext);
  Widget widget = NodeDraggableBuilder(
    node: node,
    depth: context.depth,
    builder: builder,
    configuration: configuration,
    child: NodeTargetBuilder(
      depth: context.depth,
      builder: builder,
      node: node,
      configuration: configuration,
      owner: node.owner! as NodeContainer,
      child: child,
    ),
  );

  if (wrapWithListenableBuilder) {
    widget = ListenableBuilder(
        listenable: node,
        builder: (
          BuildContext ctx,
          Widget? _,
        ) =>
            widget);
  }
  return widget;
}
