import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'scroll_target_resolver.dart';
import 'scroll_velocity.dart';

/// Drives the scrollable toward a resolved [ScrollTarget] in small,
/// incremental ticks (the "follow" loop).
///
/// Each tick re-resolves the caret against the current viewport geometry (the
/// scrollable moves, so the geometry changes), computes a delta via the
/// [physics], applies it clamped to the scroll extents, and recurses until the
/// caret is back inside the dead zone.
///
/// Coordinate contract: the target is converted to **viewport-local**
/// coordinates exactly once in [start], via `RenderBox.globalToLocal`. This
/// removes the previous `deltaToScrollOrigin` + `getTransformTo(null)` mixing
/// (which was only accidentally correct and broke under keyboard resize, nested
/// scrollables, DPR ≠ 1, and ancestor transforms).
class ScrollDriver {
  ScrollDriver(
    this.scrollable, {
    required this.resolver,
    required this.physics,
    this.onScrollViewScrolled,
    this.animationDuration = const Duration(milliseconds: 5),
  });

  final ScrollableState scrollable;
  final ScrollTargetResolver resolver;
  final ScrollVelocity physics;
  final VoidCallback? onScrollViewScrolled;
  final Duration animationDuration;

  Duration? _currentDuration;
  double? _caretDocumentOffset;
  double _currentInset = 20.0;
  bool _scrolling = false;

  /// Whether a scroll session is in progress.
  bool get isActive => _scrolling;

  /// Starts (or continues) an auto-scroll toward [globalTarget] (a global
  /// point — the caret / finger position), using [inset] as the dead zone from
  /// each viewport edge. If a session is already running, the new target is
  /// picked up on the next tick.
  void start(Offset globalTarget, {required double inset, Duration? duration}) {
    final RenderBox box = scrollable.context.findRenderObject()! as RenderBox;
    final Offset caretLocal = box.globalToLocal(globalTarget);
    // Convert to DOCUMENT (scroll-origin) coordinates. The target is fixed in
    // the document frame; as the scrollable moves (pixels changes), the
    // target's viewport-local position changes, so the overshoot converges.
    _caretDocumentOffset = scrollable.position.pixels +
        _offsetExtent(
          caretLocal,
          axisDirectionToAxis(scrollable.axisDirection),
        );
    _currentInset = inset;
    _currentDuration = duration;
    if (_scrolling) {
      // The change will be picked up in the next scroll.
      return;
    }
    _scroll();
  }

  /// Stops any ongoing auto-scroll and clears smoothing state.
  void stop() {
    _scrolling = false;
    physics.reset();
    _currentDuration = null;
  }

  Future<void> _scroll() async {
    try {
      _scrolling = true;

      final ScrollPosition position = scrollable.position;
      // Re-derive the viewport-local caret position from the (fixed) document
      // offset and the current pixels: it decreases as we scroll, so the
      // overshoot converges instead of staying constant.
      final double caretOffset = _caretDocumentOffset! - position.pixels;
      final double viewportDimension = position.viewportDimension;

      final ScrollTarget? target = resolver.resolve(
        caretOffset: caretOffset,
        viewportDimension: viewportDimension,
        inset: _currentInset,
        axisDirection: scrollable.axisDirection,
        pixels: position.pixels,
        minScrollExtent: position.minScrollExtent,
        maxScrollExtent: position.maxScrollExtent,
      );

      if (target == null) {
        // Drag should not trigger scroll.
        _scrolling = false;
        return;
      }

      final double delta = physics.deltaFor(target.overshoot);
      final double sign =
          target.direction == ScrollDirection.increase ? 1.0 : -1.0;
      double newOffset = position.pixels + sign * delta;
      newOffset = newOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );

      final double currentPixels = position.pixels;
      double deltaPixels = newOffset - currentPixels;
      if (deltaPixels.abs() < physics.minDelta) {
        if (deltaPixels.abs() <= precisionErrorTolerance) {
          _scrolling = false;
          return;
        }
        final double direction = deltaPixels.sign;
        final double targetOffset =
            (currentPixels + direction * physics.minDelta).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        newOffset = targetOffset.toDouble();
        deltaPixels = newOffset - currentPixels;
        if (deltaPixels.abs() <= precisionErrorTolerance) {
          _scrolling = false;
          return;
        }
      }

      await position.moveTo(
        newOffset,
        duration: _currentDuration ?? animationDuration,
        curve: Curves.linear,
      );
      onScrollViewScrolled?.call();
      if (_scrolling) {
        await _scroll();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _scrolling = false;
    }
  }

  double _offsetExtent(Offset offset, Axis axis) {
    return switch (axis) {
      Axis.horizontal => offset.dx,
      Axis.vertical => offset.dy,
    };
  }
}
