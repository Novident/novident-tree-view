import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/utils/platforms_utils.dart';

/// This is the painter that has the encharge
/// to paint the [CompositeTreeNode] limit lines
/// that makes more easy to the easy understand
/// where ends and where starts a [CompositeTreeNode]
class DepthLinesPainter extends CustomPainter {
  final Node node;
  final Node? lastChild;
  final double indent;
  final double height;
  final double? customOffsetX;
  final Paint? hierarchyLinePainter;
  final bool shouldPaintHierarchyLines;
  final TreeConfiguration configuration;

  DepthLinesPainter({
    required this.node,
    required this.height,
    required this.shouldPaintHierarchyLines,
    required this.configuration,
    required this.indent,
    this.customOffsetX,
    this.lastChild,
    this.hierarchyLinePainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!shouldPaintHierarchyLines || node is LeafNode) return;
    final bool isExpanded = (node as NodeContainer).isExpanded;
    final bool hasNoChildren = (node as NodeContainer).hasNoChildren;
    if (!isExpanded || (hasNoChildren && isExpanded)) return;
    final Paint paint = hierarchyLinePainter ??
        (Paint()
          ..color = Colors.grey
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke);
    final double x = customOffsetX ?? indent + getCorrectMultiplierByPlatform;
    final int endLineEffectivedy = (lastChild is NodeContainer
        ? 2
        : lastChild is LeafNode
            ? 3
            : 0);
    canvas.drawLine(
      Offset(x, height), // start of the node
      Offset(
        x,
        size.height.floorToDouble() - endLineEffectivedy,
      ), // end of the node
      paint,
    );
    /*
    canvas.drawLine(
      Offset(x, size.height.floorToDouble() - endLineEffectivedy), // end of the node
      Offset(x + 10, 0), // end of the node
      paint,
    );
    */
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return shouldPaintHierarchyLines;
  }
}
