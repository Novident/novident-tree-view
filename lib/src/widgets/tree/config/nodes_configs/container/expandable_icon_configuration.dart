import 'package:flutter/material.dart';
import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';

typedef IconBuilder = Widget? Function(NodeContainer node, BuildContext);

@immutable
class ExpandableIconConfiguration {
  /// Builder for customizing the expand/collapse icon.
  final IconBuilder? iconBuilder;

  /// The splash color applied when tapping the expand/collapse icon.
  final Color? tapSplashColor;

  /// The color applied when hovering over the expand/collapse icon.
  final Color? hoverColor;

  /// The factory used to create the splash effect when tapping the expand/collapse icon.
  final InteractiveInkFeatureFactory? splashFactory;

  /// A custom shape border for the splash effect of the expand/collapse icon.
  final ShapeBorder? customSplashShape;

  /// The border radius applied to the expand/collapse icon's splash effect.
  final BorderRadius? splashBorderRadius;

  /// Callback triggered when the expand/collapse icon is tapped.
  final void Function(NodeContainer node, BuildContext)? onIconTap;

  /// Builder for a completely custom expand/collapse widget.
  ///
  /// This allows replacing the default icon with a custom widget, while still
  /// providing the `onPressed` callback to handle the expand/collapse logic.
  final Widget Function(
    NodeContainer node,
    void Function() onPressed,
  )? customExpandableWidget;

  const ExpandableIconConfiguration({
    required this.iconBuilder,
    required this.tapSplashColor,
    required this.splashFactory,
    required this.splashBorderRadius,
    required this.customExpandableWidget,
    required this.hoverColor,
    required this.customSplashShape,
    required this.onIconTap,
  });

  /// Creates a base configuration with default values.
  ///
  /// This factory provides a starting point with default values for all properties,
  /// which can be overridden as needed.
  const ExpandableIconConfiguration.base()
      : iconBuilder = null,
        tapSplashColor = null,
        splashFactory = null,
        splashBorderRadius = null,
        customExpandableWidget = null,
        hoverColor = null,
        customSplashShape = null,
        onIconTap = null;
}
