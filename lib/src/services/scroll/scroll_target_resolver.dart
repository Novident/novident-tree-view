import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Direction in which the scrollable must move to bring the target back
/// inside the dead zone.
enum ScrollDirection {
  /// Increase the scroll offset (scroll down / right).
  increase,

  /// Decrease the scroll offset (scroll up / left).
  decrease,
}

/// The result of resolving a caret position against the viewport: which edge
/// it is near and by how much.
class ScrollTarget {
  const ScrollTarget({required this.overshoot, required this.direction});

  /// How far (in logical pixels) the caret is past the inset (dead-zone)
  /// boundary, clamped to the resolver's max overshoot.
  final double overshoot;

  /// Which way the scrollable must move to bring the caret back inside.
  final ScrollDirection direction;
}

/// Decides whether a caret position (viewport-local) is inside the viewport's
/// dead zone — defined by an [inset] from each edge — and, if not, in which
/// direction and by how much the scrollable should move.
///
/// Pure and injectable: a strategy can swap this to change the edge policy.
///
/// Coordinate contract: [caretOffset] is the caret's position along the scroll
/// axis in **viewport-local** coordinates (`0` = start of the viewport,
/// [viewportDimension] = end of the viewport). This is a single, unambiguous
/// frame — no rect inflation, no `deltaToScrollOrigin`/`getTransformTo(null)`
/// mixing.
abstract class ScrollTargetResolver {
  const ScrollTargetResolver();

  /// Returns `null` when [caretOffset] is inside the dead zone (no scroll).
  ScrollTarget? resolve({
    required double caretOffset,
    required double viewportDimension,
    required double inset,
    required AxisDirection axisDirection,
    required double pixels,
    required double minScrollExtent,
    required double maxScrollExtent,
  });
}

/// The default edge-follow resolver: an explicit symmetric [inset] (dead zone)
/// from each viewport edge. The caret may sit within [inset] px of an edge
/// without triggering auto-scroll; once it is closer than that (or past the
/// edge), the resolver reports the overshoot, capped at [maxOvershoot], and the
/// direction to scroll.
///
/// With [inset] == 0 the auto-scroll fires only once the caret actually crosses
/// the viewport edge.
class EdgeInsetResolver extends ScrollTargetResolver {
  const EdgeInsetResolver({this.maxOvershoot = 20.0});

  /// Maximum overshoot (in logical pixels) considered per resolution.
  final double maxOvershoot;

  @override
  ScrollTarget? resolve({
    required double caretOffset,
    required double viewportDimension,
    required double inset,
    required AxisDirection axisDirection,
    required double pixels,
    required double minScrollExtent,
    required double maxScrollExtent,
  }) {
    switch (axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        if (caretOffset < inset && pixels < maxScrollExtent) {
          return ScrollTarget(
            overshoot: math.min(inset - caretOffset, maxOvershoot),
            direction: ScrollDirection.increase,
          );
        }
        if (caretOffset > viewportDimension - inset &&
            pixels > minScrollExtent) {
          return ScrollTarget(
            overshoot: math.min(
              caretOffset - (viewportDimension - inset),
              maxOvershoot,
            ),
            direction: ScrollDirection.decrease,
          );
        }
        break;
      case AxisDirection.right:
      case AxisDirection.down:
        if (caretOffset < inset && pixels > minScrollExtent) {
          return ScrollTarget(
            overshoot: math.min(inset - caretOffset, maxOvershoot),
            direction: ScrollDirection.decrease,
          );
        }
        if (caretOffset > viewportDimension - inset &&
            pixels < maxScrollExtent) {
          return ScrollTarget(
            overshoot: math.min(
              caretOffset - (viewportDimension - inset),
              maxOvershoot,
            ),
            direction: ScrollDirection.increase,
          );
        }
        break;
    }
    return null;
  }
}
