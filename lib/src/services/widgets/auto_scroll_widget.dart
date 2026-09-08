import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../scroll/auto_scroller.dart';

/// The widget designed to make auto-scroll easy
/// providing the required [AutoScrollService]
/// to the Widgets Tree.
///
/// To use the auto-scroll, you have to use:
/// ```dart
/// context.read<AutoScrollerService?>()?.startAutoScroll(
///       // offset
///       globalGesturePosition,
///       inset: widget.configuration.autoScrollEdgeInset,
///       duration: const Duration(milliseconds: 2),
///     );
///
/// // And stop it when required
/// context.read<AutoScrollerService?>()?.stopAutoScroll();
/// ```
class AutoScrollWidget extends StatefulWidget {
  final Widget child;
  final AutoScrollerService Function(ScrollableState)? customScrollableService;
  const AutoScrollWidget({
    super.key,
    required this.child,
    this.customScrollableService,
  });

  @override
  State<AutoScrollWidget> createState() => _AutoScrollWidgetState();
}

class _AutoScrollWidgetState extends State<AutoScrollWidget> {
  ScrollableState? scrollableState;
  AutoScrollerService? autoScroller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty<AutoScrollerService?>(
        'autoScroller',
        autoScroller,
      ),
    );
    properties.add(
      DiagnosticsProperty<ScrollableState?>(
        'scrollableState',
        scrollableState,
      ),
    );
    super.debugFillProperties(properties);
  }

  void updateAutoScroller(
    ScrollableState scrollableState,
  ) {
    if (this.scrollableState != scrollableState) {
      autoScroller?.stopAutoScroll();
      late AutoScrollerService scroller;
      scroller = AutoScroller(
        scrollableState,
        onScrollViewScrolled: () => _onScrollViewScrolled(scroller),
      );
      autoScroller = scroller;
      this.scrollableState = scrollableState;
    }
  }

  void _onScrollViewScrolled(AutoScrollerService scroller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (autoScroller == scroller) {
        scroller.continueToAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        // We can use manually external scrollables
        //
        // Or use the main ListView Scrollable
        final scrollable =
            Scrollable.maybeOf(context) ?? Scrollable.maybeOf(ctx);
        if (scrollable != null) updateAutoScroller(scrollable);
        return Provider<AutoScrollerService?>(
          create: (BuildContext context) => autoScroller,
          child: widget.child,
        );
      },
    );
  }
}
