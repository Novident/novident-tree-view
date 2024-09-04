import 'package:flutter/material.dart';
import '../../../entities/tree_node/composite_tree_node.dart';

@immutable
class ExpandableIconConfiguration {
  final Widget? Function(CompositeTreeNode node, BuildContext)? iconBuilder;
  final Color? onTapSplashColor;
  final Color? onHoverColor;
  final Color? onExistHoverColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final int defaultExpandableAnimationDuration;
  final ShapeBorder? customSplashBorder;
  final BorderRadius? borderRadius;
  final void Function(CompositeTreeNode node, BuildContext)? onTap;
  final Widget Function(
          CompositeTreeNode node, bool isSelected, void Function() onPressed)?
      customExpandableWidget;

  const ExpandableIconConfiguration({
    this.iconBuilder,
    this.defaultExpandableAnimationDuration = 800,
    this.onTapSplashColor,
    this.splashFactory,
    this.borderRadius,
    this.customExpandableWidget,
    this.onHoverColor,
    this.onExistHoverColor,
    this.customSplashBorder,
    this.onTap,
  });
}
