import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';

@immutable
final class NodeConfiguration {
  /// The color applied when hovering over the [Node].
  final Color? hoverColor;

  /// The splash color applied when tapping the [Node].
  final Color? tapSplashColor;

  /// The factory used to create the splash effect when tapping the [Node].
  final InteractiveInkFeatureFactory? splashFactory;

  /// The border radius applied to the splash effect.
  final BorderRadius? splashBorderRadius;

  /// A custom shape border for the splash effect.
  final ShapeBorder? customSplashShape;

  /// Callback triggered when the [Node] is tapped.
  ///
  /// **Note**: This does not affect the default implementation where tapping
  /// a node selects it using the [TreeController].
  final void Function(BuildContext context)? onTap;

  /// Callback triggered when the [Node] is double-tapped.
  final void Function(BuildContext context)? onDoubleTap;

  /// Callback triggered when the [Node] is long-pressed.
  final void Function(BuildContext context)? onLongPress;

  /// Callback triggered when the [Node] is tapped with a secondary button (e.g., right-click).
  final void Function(BuildContext context)? onSecondaryTap;

  /// Callback triggered when the [Node] is hovered over or when the hover ends.
  @Deprecated('onHover is not being used and was replaced by onHoverInkWell')
  final void Function(bool isHovered, BuildContext context)? onHover;

  /// Callback triggered when the [Node] is hovered over or when the hover ends.
  final void Function(bool isHovered, BuildContext context)? onHoverInkWell;

  /// Called when the user taps down this part of the material.
  final void Function(TapDownDetails details, BuildContext context)? onTapDown;

  /// Called when the user releases a tap that was started on this part of the
  /// material. [onTap] is called immediately after.
  final void Function(TapUpDetails details, BuildContext context)? onTapUp;

  /// Called when the user cancels a tap that was started on this part of the
  /// material.
  final void Function(BuildContext context)? onTapCancel;

  /// Called when the user taps down on this part of the material with a
  /// secondary button.
  final void Function(TapDownDetails details, BuildContext context)?
      onSecondaryTapDown;

  /// Called when the user releases a secondary button tap that was started on
  /// this part of the material. [onSecondaryTap] is called immediately after.
  final void Function(TapUpDetails details, BuildContext context)?
      onSecondaryTapUp;

  /// Called when the user cancels a secondary button tap that was started on
  /// this part of the material.
  final void Function(BuildContext context)? onSecondaryTapCancel;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If this property is null, [WidgetStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// Defines the ink response focus, hover, and splash colors.
  ///
  /// This default null property can be used as an alternative to
  /// [focusColor], [hoverColor], [highlightColor], and
  /// [splashColor]. If non-null, it is resolved against one of
  /// [WidgetState.focused], [WidgetState.hovered], and
  /// [WidgetState.pressed]. It's convenient to use when the parent
  /// widget can pass along its own WidgetStateProperty value for
  /// the overlay color.
  ///
  /// [WidgetState.pressed] triggers a ripple (an ink splash), per
  /// the current Material Design spec. The [overlayColor] doesn't map
  /// a state to [highlightColor] because a separate highlight is not
  /// used by the current design guidelines. See
  /// https://material.io/design/interaction/states.html#pressed
  ///
  /// If the overlay color is null or resolves to null, then [focusColor],
  /// [hoverColor], [splashColor] and their defaults are used instead.
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The duration of the animation that animates the hover effect.
  ///
  /// The default is 50ms.
  final Duration? hoverDuration;

  /// Callback to wrap the builded node widget.
  ///
  /// You can use it to wrap all Nodes into your own implementation
  ///
  /// Example:
  ///
  /// ```dart
  /// NodeConfiguration(
  ///  // set this to false to avoid default implementation
  ///  // that wraps the node into a InkWell button
  ///  makeTappable: false,
  ///  nodeWrapper: (Node node, BuildContext context, Widget child) {
  ///    return MaterialButton(
  ///      child: child,
  ///    );
  ///  },
  /// );
  /// ```
  final Widget Function(Node node, BuildContext context, Widget child)?
      nodeWrapper;

  /// Determine if the Node should be wrapped by an InkWell
  /// Or not
  final bool makeTappable;

  /// This is the decoration of the node
  final BoxDecoration? decoration;

  final FocusNode? focusNode;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final void Function(bool)? onFocusChange;

  /// The color of the ink response when the parent widget is focused. If this
  /// property is null then the focus color of the theme,
  /// [ThemeData.focusColor], will be used.
  final Color? focusColor;

  const NodeConfiguration({
    required this.makeTappable,
    this.focusNode,
    this.onFocusChange,
    this.focusColor,
    this.decoration,
    this.hoverDuration,
    this.nodeWrapper,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.mouseCursor,
    this.overlayColor,
    this.onHoverInkWell,
    this.splashFactory,
    this.hoverColor,
    this.tapSplashColor,
    this.splashBorderRadius,
    this.customSplashShape,
    // ignore: deprecated_member_use_from_same_package
  }) : onHover = null;
}
