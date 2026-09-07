import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';

/// Wraps a top-level block and paints a translucent green background while the
/// block lies within the editor's visible range.
///
/// Plugs into [NovidentEditor.blockWrapper]. It listens to the scroll
/// controller's [EditorScrollController.visibleRangeNotifier], so visibility
/// updates re-evaluate only the color — [child] is passed through untouched
/// and is never rebuilt.
class VisibleBlockWrapper extends StatelessWidget {
  const VisibleBlockWrapper({
    super.key,
    required this.scrollController,
    required this.node,
    required this.child,
    this.visibleColor = const Color(0x644CAF50),
  });

  final EditorScrollController scrollController;

  /// The top-level node wrapped by this widget.
  final Node node;

  final Widget child;

  /// The background painted while [node] is visible. Defaults to a translucent
  /// green (alpha 100).
  final Color visibleColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<(int, int)>(
      valueListenable: scrollController.visibleRangeNotifier,
      child: child,
      builder: (context, range, child) {
        final (min, max) = range;
        final index = node.path.isEmpty ? -1 : node.path.first;
        final visible = min >= 0 && max >= 0 && index >= min && index <= max;
        return ColoredBox(
          color: visible ? visibleColor : Colors.red,
          child: child,
        );
      },
    );
  }
}
