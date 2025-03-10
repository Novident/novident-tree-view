import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

typedef LeafDecorationBuilder = BoxDecoration Function(
  LeafNode node,
);

@immutable
class LeafConfiguration {
  final Color? onHoverColor;
  final Color? onExistHoverColor;
  final Color? onTapSplashColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final BorderRadius? borderSplashRadius;
  final ShapeBorder? customSplashBorder;
  final EdgeInsets padding;
  final double? height;

  /// This doesn't affect the default implementation
  /// where on tap an item this will be selected
  /// using TreeController
  final void Function(Node node, BuildContext context)? onTap;
  final void Function(Node node, BuildContext context)? onDoubleTap;
  final void Function(Node node, BuildContext context)? onSecundaryTap;
  final void Function(Node node, bool isHovered, BuildContext context)? onHover;
  final MouseCursor? cursor;
  final LeafDecorationBuilder boxDecoration;
  // widgets
  final Widget Function(LeafNode node, double indent, BuildContext context)
      leading;
  final Widget Function(LeafNode node, double indent, BuildContext context)
      content;
  final Widget? Function(LeafNode node, double indent, BuildContext context)?
      trailing;

  /// Wrap the Leaf item into your custom widget
  /// to add more features to it
  final Widget Function(Widget leafWidget)? wrapper;

  final NodeDragGestures? dragGestures;

  const LeafConfiguration({
    required this.boxDecoration,
    required this.padding,
    required this.height,
    required this.leading,
    required this.content,
    this.dragGestures,
    this.wrapper,
    this.onTap,
    this.onSecundaryTap,
    this.cursor,
    this.onHover,
    this.onDoubleTap,
    this.splashFactory,
    this.trailing,
    this.onHoverColor,
    this.onExistHoverColor,
    this.onTapSplashColor,
    this.borderSplashRadius,
    this.customSplashBorder,
  });
}
