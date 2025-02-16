import 'package:flutter/material.dart';
import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';

typedef IconBuilder = Widget? Function(NodeContainer node, BuildContext);

@immutable
class ExpandableIconConfiguration {
  final IconBuilder? iconBuilder;
  final Color? onTapSplashColor;
  final Color? onHoverColor;
  final Color? onExistHoverColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final int defaultExpandableAnimationDuration;
  final ShapeBorder? customSplashBorder;
  final BorderRadius? borderRadius;
  final void Function(NodeContainer node, BuildContext)? onTap;
  final Widget Function(NodeContainer node, void Function() onPressed)?
      customExpandableWidget;

  const ExpandableIconConfiguration({
    required this.iconBuilder,
    required this.defaultExpandableAnimationDuration,
    required this.onTapSplashColor,
    required this.splashFactory,
    required this.borderRadius,
    required this.customExpandableWidget,
    required this.onHoverColor,
    required this.onExistHoverColor,
    required this.customSplashBorder,
    required this.onTap,
  });

  factory ExpandableIconConfiguration.base() {
    return const ExpandableIconConfiguration(
      defaultExpandableAnimationDuration: 800,
      iconBuilder: null,
      onTapSplashColor: null,
      splashFactory: null,
      borderRadius: null,
      customExpandableWidget: null,
      onHoverColor: null,
      onExistHoverColor: null,
      customSplashBorder: null,
      onTap: null,
    );
  }
}
