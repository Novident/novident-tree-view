import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Converts an overshoot (how far the target overflows the viewport edge)
/// into a scroll delta for a single tick.
///
/// Pure and injectable: a strategy can swap this to change the velocity
/// profile (linear, smoothed, ballistic, ...).
abstract class ScrollVelocity {
  /// The least amount of scroll delta applied per tick.
  double get minDelta;

  /// Returns the delta (in logical pixels) for [overshoot].
  double deltaFor(double overshoot);

  /// Clears any internal smoothing state (called when a scroll session ends).
  void reset();
}

/// The default velocity profile: `delta = overshoot * velocityScalar`,
/// clamped to `[minDelta, maxDelta]` and smoothed toward the previous delta
/// with an 0.8 lerp to avoid abrupt jumps between ticks.
///
/// This reproduces the `_smoothScrollDelta` logic that used to live inside
/// `EdgeDraggingAutoScroller`.
class SmoothScrollVelocity implements ScrollVelocity {
  SmoothScrollVelocity({
    this.velocityScalar = 7.0,
    this.minDelta = 1.0,
    this.maxDelta = 20.0,
  })  : assert(minDelta >= 0),
        assert(maxDelta >= minDelta);

  /// The velocity scalar per pixel of overscroll.
  final double velocityScalar;

  @override
  final double minDelta;

  /// The largest scroll delta applied per tick.
  final double maxDelta;

  double? _previousScrollDelta;

  @override
  double deltaFor(double overshoot) {
    if (overshoot <= precisionErrorTolerance) {
      return 0;
    }
    final double desiredDelta = overshoot * velocityScalar;
    final double clampedDelta = desiredDelta.clamp(minDelta, maxDelta);
    if (_previousScrollDelta == null) {
      _previousScrollDelta = clampedDelta;
      return clampedDelta;
    }
    final double smoothed =
        lerpDouble(_previousScrollDelta!, clampedDelta, 0.8)!;
    _previousScrollDelta = smoothed;
    return smoothed;
  }

  @override
  void reset() {
    _previousScrollDelta = null;
  }
}
