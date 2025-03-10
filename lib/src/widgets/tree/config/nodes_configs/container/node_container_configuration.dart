import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

typedef ContainerDecorationBuilder = BoxDecoration Function(
  NodeContainer node,
);

const double kDefaultLeftIndent = 10;

@immutable
class ContainerConfiguration {
  /// If you want to remove the expandable node
  /// button, set this to false
  ///
  /// You will need to implement your own logic to open the [NodeContainer]
  /// in [onTap] method
  final bool showDefaultExpandableButton;
  final Color? onHoverColor;
  final Color? onExistHoverColor;
  final Color? onTapSplashColor;

  final EdgeInsets padding;
  final double childrenLeftIndent;

  /// The height of the node container widget
  final double height;
  final InteractiveInkFeatureFactory? splashFactory;
  final BorderRadius? borderSplashRadius;
  final ShapeBorder? customSplashBorder;

  /// This doesn't affect the default implementation
  /// where on tap an item this will be selected
  /// using TreeController
  final void Function(NodeContainer node, BuildContext context)? onTap;
  final void Function(NodeContainer node, BuildContext context)? onDoubleTap;
  final void Function(NodeContainer node, BuildContext context)? onSecundaryTap;
  final void Function(NodeContainer node, bool isHovered, BuildContext context)?
      onHover;
  final ContainerDecorationBuilder boxDecoration;
  final MouseCursor? expandableMouseCursor;
  final MouseCursor cursor;
  // widgets
  final Widget Function(NodeContainer node, double indent, BuildContext context)
      leading;
  final Widget Function(NodeContainer node, double indent, BuildContext context)
      content;
  final Widget? Function(
      NodeContainer node, double indent, BuildContext context)? trailing;
  final ExpandableIconConfiguration? expandableIconConfiguration;

  /// Wrap the Composite item into your custom widget
  /// to add more features to it
  final Widget Function(Widget leafWidget)? wrapper;
  final NodeDragGestures? dragGestures;

  const ContainerConfiguration({
    required this.boxDecoration,
    required this.padding,
    required this.height,
    required this.leading,
    required this.content,
    this.dragGestures,
    this.wrapper,
    this.onTap,
    this.childrenLeftIndent = kDefaultLeftIndent,
    this.showDefaultExpandableButton = true,
    this.onSecundaryTap,
    this.cursor = SystemMouseCursors.click,
    this.trailing,
    this.onHoverColor,
    this.onExistHoverColor,
    this.onTapSplashColor,
    this.borderSplashRadius,
    this.customSplashBorder,
    this.expandableIconConfiguration,
    this.splashFactory,
    this.onDoubleTap,
    this.onHover,
    this.expandableMouseCursor,
  });
}
