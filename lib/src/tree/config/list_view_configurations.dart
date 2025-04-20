import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Configuration class for customizing ListView behavior within tree structures.
final class ListViewConfigurations {
  /// Controller for the main scroll view
  ///
  /// When null, creates an internal ScrollController automatically.
  /// Useful for programmatic scroll control or saving scroll position.
  final ScrollController? scrollController;

  /// Whether the list should shrink-wrap its contents
  ///
  /// Defaults to true for better performance in tree views. Set to false
  /// when the list has unbounded constraints or is nested in another scrollable.
  final bool shrinkWrap;

  /// Whether this is the primary scroll view
  ///
  /// When null (default), automatically determines primary status based on
  /// widget tree context.
  final bool? primary;

  /// Content clipping behavior
  ///
  /// Defaults to [Clip.hardEdge] when null. Consider [Clip.antiAlias]
  /// for smoother edges in visual hierarchies.
  final Clip? clipBehavior;

  /// Scroll physics for the main tree view
  ///
  /// When null, uses platform-appropriate physics. Set to [NeverScrollableScrollPhysics]
  /// to disable scrolling programmatically.
  final ScrollPhysics? physics;

  /// Whether to reverse the scroll direction
  ///
  /// Defaults to false (top-to-bottom scrolling). Set to true for bottom-up
  /// display in specialized tree layouts.
  final bool reverse;

  /// Whether to automatically add semantic indexes
  ///
  /// Defaults to true for accessibility support. Set to false only if
  /// manually managing semantics for performance optimization.
  final bool addSemanticIndexes;

  /// Whether to automatically maintain state for off-screen items
  ///
  /// Defaults to true for proper state preservation. Disable only when
  /// implementing custom keep-alive logic.
  final bool addAutomaticKeepAlives;

  /// Pre-rendered area outside visible content
  ///
  /// Improves scroll performance by caching off-screen content. Measured in
  /// logical pixels. Null uses platform defaults.
  final double? cacheExtent;

  /// Fixed extent for all children (in logical pixels)
  ///
  /// When specified, forces uniform child sizing for performance optimization.
  /// Null allows variable-sized children.
  final double? itemExtent;

  /// Prototype item for estimating child sizes
  ///
  /// Used when [itemExtent] is null but approximate sizing is needed
  /// for layout calculations.
  final Widget? prototypeItem;

  /// Callback for custom child index lookup
  ///
  /// Enables dynamic reordering of children without rebuilding the entire list.
  final int? Function(Key)? findChildIndexCallback;

  /// Semantic child count for accessibility
  ///
  /// Overrides automatic counting when dealing with partially loaded trees
  /// or virtualized content.
  final int? semanticChildCount;

  /// Hit testing behavior for scrollable areas
  ///
  /// Defaults to [HitTestBehavior.opaque]. Adjust for specialized touch handling
  /// in interactive tree nodes.
  final HitTestBehavior hitTestBehavior;

  /// Restoration ID for scroll position persistence
  ///
  /// When provided, saves/restores scroll position across app sessions.
  final String? restorationId;

  /// Behavior when drag gestures start
  ///
  /// Defaults to [DragStartBehavior.start]. Adjust for specialized drag-and-drop
  /// handling in tree implementations.
  final DragStartBehavior dragStartBehavior;

  /// Dynamic item extent calculator
  ///
  /// When specified, overrides both [itemExtent] and [prototypeItem] to provide
  /// per-item sizing control.
  final double? Function(int, SliverLayoutDimensions)? itemExtentBuilder;

  /// Keyboard dismissal behavior during scrolling
  ///
  /// Defaults to [ScrollViewKeyboardDismissBehavior.manual]. Controls how
  /// on-screen keyboard interacts with scroll gestures.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Creates configuration for tree list views
  const ListViewConfigurations({
    this.scrollController,
    this.shrinkWrap = true,
    this.primary,
    this.clipBehavior,
    this.physics,
    this.reverse = false,
    this.addSemanticIndexes = true,
    this.addAutomaticKeepAlives = true,
    this.cacheExtent,
    this.itemExtent,
    this.prototypeItem,
    this.findChildIndexCallback,
    this.semanticChildCount,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.restorationId,
    this.dragStartBehavior = DragStartBehavior.start,
    this.itemExtentBuilder,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  /// Creates a copy with modified parameters
  ListViewConfigurations copyWith({
    ScrollController? scrollController,
    bool? shrinkWrap,
    bool? primary,
    Clip? clipBehavior,
    ScrollPhysics? physics,
    bool? reverse,
    bool? addSemanticIndexes,
    bool? addAutomaticKeepAlives,
    double? cacheExtent,
    double? itemExtent,
    Widget? prototypeItem,
    int? Function(Key)? findChildIndexCallback,
    int? semanticChildCount,
    HitTestBehavior? hitTestBehavior,
    String? restorationId,
    DragStartBehavior? dragStartBehavior,
    double? Function(int, SliverLayoutDimensions)? itemExtentBuilder,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
  }) {
    return ListViewConfigurations(
      scrollController: scrollController ?? this.scrollController,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      primary: primary ?? this.primary,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      physics: physics ?? this.physics,
      reverse: reverse ?? this.reverse,
      addSemanticIndexes: addSemanticIndexes ?? this.addSemanticIndexes,
      addAutomaticKeepAlives:
          addAutomaticKeepAlives ?? this.addAutomaticKeepAlives,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      itemExtent: itemExtent ?? this.itemExtent,
      prototypeItem: prototypeItem ?? this.prototypeItem,
      findChildIndexCallback:
          findChildIndexCallback ?? this.findChildIndexCallback,
      semanticChildCount: semanticChildCount ?? this.semanticChildCount,
      hitTestBehavior: hitTestBehavior ?? this.hitTestBehavior,
      restorationId: restorationId ?? this.restorationId,
      dragStartBehavior: dragStartBehavior ?? this.dragStartBehavior,
      itemExtentBuilder: itemExtentBuilder ?? this.itemExtentBuilder,
      keyboardDismissBehavior:
          keyboardDismissBehavior ?? this.keyboardDismissBehavior,
    );
  }

  @override
  bool operator ==(covariant ListViewConfigurations other) {
    if (identical(this, other)) return true;

    return other.scrollController == scrollController &&
        other.shrinkWrap == shrinkWrap &&
        other.primary == primary &&
        other.clipBehavior == clipBehavior &&
        other.physics == physics &&
        other.reverse == reverse &&
        other.addSemanticIndexes == addSemanticIndexes &&
        other.addAutomaticKeepAlives == addAutomaticKeepAlives &&
        other.cacheExtent == cacheExtent &&
        other.itemExtent == itemExtent &&
        other.prototypeItem == prototypeItem &&
        other.findChildIndexCallback == findChildIndexCallback &&
        other.semanticChildCount == semanticChildCount &&
        other.hitTestBehavior == hitTestBehavior &&
        other.restorationId == restorationId &&
        other.dragStartBehavior == dragStartBehavior &&
        other.itemExtentBuilder == itemExtentBuilder &&
        other.keyboardDismissBehavior == keyboardDismissBehavior;
  }

  @override
  int get hashCode => Object.hashAll([
        scrollController,
        shrinkWrap,
        primary,
        clipBehavior,
        physics,
        reverse,
        addSemanticIndexes,
        addAutomaticKeepAlives,
        cacheExtent,
        itemExtent,
        prototypeItem,
        findChildIndexCallback,
        semanticChildCount,
        hitTestBehavior,
        restorationId,
        dragStartBehavior,
        itemExtentBuilder,
        keyboardDismissBehavior,
      ]);

  @override
  String toString() => 'ListViewConfigurations('
      'scrollController: $scrollController, '
      'shrinkWrap: $shrinkWrap, '
      'primary: $primary, '
      'clipBehavior: $clipBehavior, '
      'physics: $physics, '
      'reverse: $reverse, '
      'cacheExtent: $cacheExtent, '
      'restorationId: $restorationId'
      ')';
}
