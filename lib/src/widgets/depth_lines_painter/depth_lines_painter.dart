import 'package:flutter/material.dart';
import '../../entities/tree_node/composite_tree_node.dart';
import '../../entities/tree_node/leaf_tree_node.dart';
import '../../utils/compute_padding_by_level.dart';
import '../../entities/tree_node/tree_node.dart';
import '../tree/config/tree_configuration.dart';

/// This is the painter that has the encharge
/// to paint the [CompositeTreeNode] limit lines
/// that makes more easy to the easy understand
/// where ends and where starts a [CompositeTreeNode]
class DepthLinesPainter extends CustomPainter {
  final TreeNode node;
  final TreeNode? lastChild;
  final double height;
  final double? customOffsetX;
  final Paint? customPainter;
  final bool shouldPaint;
  final TreeConfiguration configuration;

  DepthLinesPainter(
    this.node,
    this.height,
    this.customOffsetX,
    this.shouldPaint,
    this.lastChild,
    this.customPainter,
    this.configuration,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (!shouldPaint || node is LeafTreeNode) return;
    final isExpanded = (node as CompositeTreeNode).isExpanded;
    final hasNoChildren = (node as CompositeTreeNode).hasNoChildren;
    if (!isExpanded || (hasNoChildren && isExpanded)) return;
    final paint = customPainter ?? Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final indent = configuration.compositeConfiguration.showExpandableButton ||
            configuration.compositeConfiguration.expandableIconConfiguration
                    ?.customExpandableWidget !=
                null
        ? computePaddingForComposite(node.level)
        : configuration.customComputeNodeIndentByLevel?.call(node) ??
            computePaddingForCompositeWithoutExpandable(node.level);
    final x = customOffsetX ?? indent + 27.5;
    canvas.drawLine(
      Offset(x, height), // empieza en el nivel del nodo
      Offset(
        x,
        size.height.floorToDouble() -
            (lastChild is CompositeTreeNode
                ? 2
                : lastChild is LeafTreeNode
                    ? 3
                    : 0),
      ), // termina al final del nodo
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return shouldPaint;
  }
}
