import 'package:flutter/material.dart';
import 'package:novident_editor_core/novident_editor_core.dart';
import 'package:novident_editor_selection/novident_editor_selection.dart';

/// Animated rainbow gradient selection highlight that cycles through
/// colors over time.
///
/// Uses [AnimatedSelectionAreaPaint] from novident_selection's painter
/// with custom colors and a 3-second looped animation.
class RainbowSelectionRenderer extends DefaultSelectionRenderer {
  const RainbowSelectionRenderer({
    this.colors = const [
      Color(0xFF4158D0), // blue
      Color(0xFFC850C0), // pink
      Color(0xFFFFCC70), // gold
    ],
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.easeInOut,
  });

  /// The gradient colors used for the animated selection highlight.
  /// Must have at least 2 colors.
  final List<Color> colors;

  /// Duration of one full gradient rotation cycle.
  final Duration duration;

  /// Easing curve for the rotation animation.
  final Curve curve;

  @override
  Widget buildSelectionHighlight(SelectionPaintContext ctx) {
    return AnimatedSelectionAreaPaint(
      rects: ctx.rects,
      colors: colors,
      duration: duration,
      curve: curve,
      withAnimation: true,
    );
  }

  @override
  Widget buildCursor(CursorPaintContext ctx) {
    // Use a thin colored cursor that matches the rainbow theme.
    return Cursor(
      rect: ctx.rect,
      color: colors.first.withValues(alpha: 0.9),
      cursorStyle: CursorStyle.verticalLine,
      shouldBlink: ctx.shouldBlink,
    );
  }
}
