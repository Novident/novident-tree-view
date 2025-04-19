import 'package:flutter/material.dart';

class ListViewConfigurations {
  /// Controller for the main scroll view
  final ScrollController? scrollController;

  /// Whether the list should shrink-wrap its contents
  final bool shrinkWrap;

  /// Whether this is the primary scroll view
  final bool? primary;

  /// Content clipping behavior
  final Clip? clipBehavior;

  /// Scroll physics for the main tree view
  final ScrollPhysics? physics;

  const ListViewConfigurations({
    this.physics,
    this.scrollController,
    this.shrinkWrap = true,
    this.primary,
    this.clipBehavior,
  });

  @override
  bool operator ==(covariant ListViewConfigurations other) {
    if (identical(other, this)) return true;
    return physics == other.physics &&
        scrollController == other.scrollController &&
        shrinkWrap == other.shrinkWrap &&
        clipBehavior == other.clipBehavior;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
        <Object?>[
          scrollController,
          shrinkWrap,
          primary,
          clipBehavior,
          physics,
        ],
      );
}
