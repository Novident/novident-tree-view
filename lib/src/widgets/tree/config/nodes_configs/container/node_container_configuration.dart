import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

typedef ContainerDecorationBuilder = BoxDecoration Function(
  NodeContainer node,
);

const double kDefaultLeftIndent = 10;

@immutable
class ContainerConfiguration {
  /// Determines whether to display the default expand/collapse button for [NodeContainer].
  ///
  /// If set to `false`, the default button will be hidden, and you must implement
  /// custom logic to handle expanding/collapsing the [NodeContainer] in the [onTap] method.
  final bool showDefaultExpandableButton;

  /// The color applied when hovering over the [NodeContainer].
  final Color? hoverColor;

  /// The color applied when hovering over an already expanded [NodeContainer].
  final Color? expandedHoverColor;

  /// The splash color applied when tapping the [NodeContainer].
  final Color? tapSplashColor;

  /// The padding applied to the [NodeContainer].
  final EdgeInsets? padding;

  /// The indentation applied to the children of the [NodeContainer].
  final double childrenLeftIndent;

  /// The height of the [NodeContainer] widget.
  final double? widgetHeight;

  /// The factory used to create the splash effect when tapping the [NodeContainer].
  final InteractiveInkFeatureFactory? splashFactory;

  /// The border radius applied to the splash effect.
  final BorderRadius? splashBorderRadius;

  /// A custom shape border for the splash effect.
  final ShapeBorder? customSplashShape;

  /// Callback triggered when the [NodeContainer] is tapped.
  final void Function(NodeContainer node, BuildContext context)? onTap;

  /// Callback triggered when the [NodeContainer] is double-tapped.
  final void Function(NodeContainer node, BuildContext context)? onDoubleTap;

  /// Callback triggered when the [NodeContainer] is tapped with a secondary button (e.g., right-click).
  final void Function(NodeContainer node, BuildContext context)? onSecondaryTap;

  /// Callback triggered when the [NodeContainer] is hovered over or when the hover ends.
  final void Function(NodeContainer node, bool isHovered, BuildContext context)?
      onHover;

  /// Builder for customizing the decoration of the [NodeContainer].
  final ContainerDecorationBuilder? boxDecoration;

  /// The mouse cursor displayed when hovering over the expand/collapse button.
  final MouseCursor? expandableButtonCursor;

  /// The mouse cursor displayed when hovering over the [NodeContainer].
  final MouseCursor cursor;

  /// Builder for the leading widget of the [NodeContainer].
  final Widget Function(NodeContainer node, BuildContext context) leading;

  /// Builder for the main content widget of the [NodeContainer].
  final Widget Function(NodeContainer node, BuildContext context) content;

  /// Builder for the trailing widget of the [NodeContainer].
  final Widget? Function(NodeContainer node, BuildContext context)? trailing;

  /// Configuration for the expand/collapse icon.
  final ExpandableIconConfiguration? expandableIconConfiguration;

  /// Wraps the [NodeContainer] widget with a custom widget to add additional features.
  final Widget Function(Widget leafWidget)? wrapper;

  /// Gesture configurations for drag-and-drop interactions with the [NodeContainer].
  final NodeDragGestures? dragGestures;

  const ContainerConfiguration({
    required this.leading,
    required this.content,
    this.padding,
    this.boxDecoration,
    this.widgetHeight,
    this.dragGestures,
    this.wrapper,
    this.onTap,
    this.childrenLeftIndent = kDefaultLeftIndent,
    this.showDefaultExpandableButton = true,
    this.onSecondaryTap,
    this.cursor = SystemMouseCursors.click,
    this.trailing,
    this.hoverColor,
    this.expandedHoverColor,
    this.tapSplashColor,
    this.splashBorderRadius,
    this.customSplashShape,
    this.expandableIconConfiguration,
    this.splashFactory,
    this.onDoubleTap,
    this.onHover,
    this.expandableButtonCursor,
  });
}
