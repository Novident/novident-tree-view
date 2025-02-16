import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import '../../entities/node/node.dart';
import '../tree/config/tree_configuration.dart';

// These multiplier are using by Platform
// since the screen size is minor than the desktop
// screens, so, we need to adjust the draw offset
// to make more easy for mobiles adapt to their parents
// without go out of them easily
const double _desktopIndentMultiplier = 27.5;
const double _androidIndentMultiplier = 24.5;

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
    this.indent,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (!shouldPaint || node is LeafNode) return;
    final isExpanded = (node as NodeContainer).isExpanded;
    final hasNoChildren = (node as NodeContainer).hasNoChildren;
    if (!isExpanded || (hasNoChildren && isExpanded)) return;
    final paint = customPainter ?? Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final x = customOffsetX ?? indent + _getCorrectMultiplierByPlatform;
    final endLineEffectivedy = (lastChild is NodeContainer
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

  double get _getCorrectMultiplierByPlatform =>
      Platform.isIOS || Platform.isAndroid || Platform.isFuchsia
          ? _androidIndentMultiplier
          : _desktopIndentMultiplier;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return shouldPaint;
  }
}
