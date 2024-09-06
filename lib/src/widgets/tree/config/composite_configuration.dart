import 'package:flutter/material.dart';

import '../../../entities/tree_node/composite_tree_node.dart';
import '../../../entities/tree_node/tree_node.dart';
import 'expandable_icon_configuration.dart';

typedef CustomCompositeDecorationBuilder = BoxDecoration Function(
  CompositeTreeNode node,
  bool isSelected,
  bool isDraggedObjectAboveThisNode,
);

@immutable
class CompositeConfiguration {
  /// If you want to remove the expandable node
  /// button, set this to false
  ///
  /// You will need to implement your own logic to open the [CompositeTreeNode]
  /// using [onTap] option to avoid non expandable nodes because the unique way
  /// to open a [CompositeTreeNode] is using by default the expandable button
  final bool showExpandableButton;
  final Color? onHoverColor;
  final Color? onExistHoverColor;
  final Color? onTapSplashColor;

  /// If a node is dragged above this (literalle above) and will
  /// be inserted into this [CompositeTreeNode] then this is
  /// be called to paint
  final Color Function(TreeNode node)? onDraggedNodeIsAbove;
  final EdgeInsets padding;
  final double childrenLeftIndent;
  final double height;
  final InteractiveInkFeatureFactory? splashFactory;
  final BorderRadius? borderSplashRadius;
  final ShapeBorder? customSplashBorder;

  /// This doesn't affect the default implementation
  /// where on tap an item this will be selected
  /// using TreeController
  final void Function(TreeNode node, BuildContext context)? onTap;
  final void Function(TreeNode node, BuildContext context)? onDoubleTap;
  final void Function(TreeNode node, BuildContext context)? onSecundaryTap;
  final void Function(TreeNode node, bool isHovered, BuildContext context)?
      onHover;
  final CustomCompositeDecorationBuilder compositeBoxDecoration;
  final MouseCursor? expandableMouseCursor;
  final MouseCursor compositeMouseCursor;
  // widgets
  final Widget Function(
      CompositeTreeNode node, double indent, BuildContext context) leading;
  final Widget Function(
      CompositeTreeNode node, double indent, BuildContext context) content;
  final Widget? Function(
      CompositeTreeNode node, double indent, BuildContext context)? trailing;
  final ExpandableIconConfiguration? expandableIconConfiguration;
  /// Wrap the Composite item into your custom widget 
  /// to add more features to it
  final Widget Function(Widget leafWidget)? wrapper;

  const CompositeConfiguration({
    required this.compositeBoxDecoration,
    required this.padding,
    required this.height,
    required this.leading,
    required this.content,
    this.wrapper,
    this.onTap,
    this.childrenLeftIndent = 10,
    this.showExpandableButton = true,
    this.onSecundaryTap,
    this.compositeMouseCursor = SystemMouseCursors.click,
    this.trailing,
    this.onHoverColor,
    this.onExistHoverColor,
    this.onTapSplashColor,
    this.borderSplashRadius,
    this.customSplashBorder,
    this.onDraggedNodeIsAbove,
    this.expandableIconConfiguration,
    this.splashFactory,
    this.onDoubleTap,
    this.onHover,
    this.expandableMouseCursor,
  });
}
