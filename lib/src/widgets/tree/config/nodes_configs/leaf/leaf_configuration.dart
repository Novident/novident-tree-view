import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

typedef LeafDecorationBuilder = BoxDecoration Function(
  LeafNode node,
);

@immutable
class LeafConfiguration {
  /// The color applied when hovering over the [LeafNode].
  final Color? hoverColor;

  /// The color applied when hovering over an already selected [LeafNode].
  final Color? selectedHoverColor;

  /// The splash color applied when tapping the [LeafNode].
  final Color? tapSplashColor;

  /// The factory used to create the splash effect when tapping the [LeafNode].
  final InteractiveInkFeatureFactory? splashFactory;

  /// The border radius applied to the splash effect.
  final BorderRadius? splashBorderRadius;

  /// A custom shape border for the splash effect.
  final ShapeBorder? customSplashShape;

  /// The padding applied to the [LeafNode].
  final EdgeInsets? padding;

  /// The height of the [LeafNode] widget.
  final double? widgetHeight;

  /// Callback triggered when the [LeafNode] is tapped.
  ///
  /// **Note**: This does not affect the default implementation where tapping
  /// a node selects it using the [TreeController].
  final void Function(Node node, BuildContext context)? onTap;

  /// Callback triggered when the [LeafNode] is double-tapped.
  final void Function(Node node, BuildContext context)? onDoubleTap;

  /// Callback triggered when the [LeafNode] is tapped with a secondary button (e.g., right-click).
  final void Function(Node node, BuildContext context)? onSecondaryTap;

  /// Callback triggered when the [LeafNode] is hovered over or when the hover ends.
  final void Function(Node node, bool isHovered, BuildContext context)? onHover;

  /// The mouse cursor displayed when hovering over the [LeafNode].
  final MouseCursor? cursor;

  /// Builder for customizing the decoration of the [LeafNode].
  final LeafDecorationBuilder? boxDecoration;

  /// Builder for the leading widget of the [LeafNode].
  final Widget Function(LeafNode node, BuildContext context) leading;

  /// Builder for the main content widget of the [LeafNode].
  final Widget Function(LeafNode node, BuildContext context) content;

  /// Builder for the trailing widget of the [LeafNode].
  final Widget? Function(LeafNode node, BuildContext context)? trailing;

  /// Wraps the [LeafNode] widget with a custom widget to add additional features.
  final Widget Function(Widget leafWidget)? wrapper;

  /// Gesture configurations for drag-and-drop interactions with the [LeafNode].
  final NodeDragGestures? dragGestures;

  const LeafConfiguration({
    required this.leading,
    required this.content,
    this.boxDecoration,
    this.padding,
    this.widgetHeight,
    this.dragGestures,
    this.wrapper,
    this.onTap,
    this.onSecondaryTap,
    this.cursor,
    this.onHover,
    this.onDoubleTap,
    this.splashFactory,
    this.trailing,
    this.hoverColor,
    this.selectedHoverColor,
    this.tapSplashColor,
    this.splashBorderRadius,
    this.customSplashShape,
  });
}
