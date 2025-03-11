import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/utils/platforms_utils.dart';
import 'package:meta/meta.dart';

final Paint kDefaultHierarchyStylePainter = Paint()
  ..color = Colors.grey
  ..strokeWidth = 1.0
  ..style = PaintingStyle.stroke;

const double _endLineLength = 2.8;
const double _lastChildEndLineLength = 4.0; // Shorter line for the last child
const double _verticalLineEndOffset = 0.90; // Adjust vertical line end position

/// This is the painter that has the encharge
/// to paint the [NodeContainer] hierarchy lines
/// that makes more easy to the easy understand
/// where ends and where starts a [NodeContainer]
class HierarchyLinePainter extends CustomPainter {
  final NodeContainer nodeContainer;
  final Node? lastChild;
  final double indent;
  final double? customOffsetX;
  final Paint? hierarchyLinePainter;
  final bool shouldPaintHierarchyLines;
  final TreeConfiguration configuration;

  HierarchyLinePainter({
    required this.nodeContainer,
    required this.shouldPaintHierarchyLines,
    required this.configuration,
    required this.indent,
    this.customOffsetX,
    this.lastChild,
    this.hierarchyLinePainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!shouldPaintHierarchyLines) return;

    if (!nodeContainer.isExpanded || nodeContainer.isEmpty) {
      return;
    }

    final Paint paint = hierarchyLinePainter ?? kDefaultHierarchyStylePainter;
    final double x = customOffsetX ?? indent + getCorrectMultiplierByPlatform;

    // Calculate the end position of the vertical line
    final double verticalLineEndY = _calculateVerticalLineEndY(size);

    // Draw the vertical line
    _drawVerticalLine(
        canvas, x, size.height * _verticalLineEndOffset, verticalLineEndY, paint);

    // Draw the horizontal end line
    //
    // by now we don't run this, since it's still in a experimental phase
    // _drawHorizontalEndLine(canvas, x, verticalLineEndY - 23, paint, isLastChild: lastChild != null);
  }

  double _calculateVerticalLineEndY(Size size) {
    if (lastChild == null) return size.height;

    // Adjust the end position of the vertical line for the last child
    return size.height -
        (lastChild is LeafNode ? _lastChildEndLineLength : _endLineLength);
  }

  void _drawVerticalLine(
      Canvas canvas, double x, double startY, double endY, Paint paint) {
    canvas.drawLine(
      Offset(x, startY),
      Offset(x, endY),
      paint,
    );
  }

  @experimental
  // ignore: unused_element
  void _drawHorizontalEndLine(Canvas canvas, double x, double y, Paint paint,
      {required bool isLastChild}) {
    final double endLineLength =
        isLastChild ? _lastChildEndLineLength : _endLineLength;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + endLineLength, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
