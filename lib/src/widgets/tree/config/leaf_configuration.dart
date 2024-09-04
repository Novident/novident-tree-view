import 'package:flutter/material.dart';
import '../../../entities/tree_node/leaf_tree_node.dart';
import '../../../entities/tree_node/tree_node.dart';

typedef CustomLeafDecorationBuilder = BoxDecoration Function(
  LeafTreeNode node,
  bool isSelected,
  bool isDraggedObjectAboveThisNode,
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
  final double height;

  /// This doesn't affect the default implementation
  /// where on tap an item this will be selected
  /// using TreeController
  final void Function(TreeNode node, BuildContext context)? onTap;
  final void Function(TreeNode node, BuildContext context)? onDoubleTap;
  final void Function(TreeNode node, BuildContext context)? onSecundaryTap;
  final void Function(TreeNode node, bool isHovered, BuildContext context)?
      onHover;
  final MouseCursor? mouseCursor;
  final CustomLeafDecorationBuilder leafBoxDecoration;
  // widgets
  final Widget Function(LeafTreeNode node, double indent, BuildContext context)
      leading;
  final Widget Function(LeafTreeNode node, double indent, BuildContext context)
      content;
  final Widget? Function(
      LeafTreeNode node, double indent, BuildContext context)? trailing;

  const LeafConfiguration({
    required this.leafBoxDecoration,
    required this.padding,
    required this.height,
    required this.leading,
    required this.content,
    this.onTap,
    this.onSecundaryTap,
    this.mouseCursor,
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
