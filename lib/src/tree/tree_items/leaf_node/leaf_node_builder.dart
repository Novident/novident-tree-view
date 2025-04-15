import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// Represents the leaf [Node] into the Tree
class LeafNodeBuilder extends StatefulWidget {
  final int depth;

  /// The [ContainerTreeNode] item
  final Node node;

  /// The owner of this [NodeContainer]
  final NodeContainer owner;

  final TreeConfiguration configuration;

  LeafNodeBuilder({
    required this.node,
    required this.owner,
    required this.configuration,
    required this.depth,
    super.key,
  });

  @override
  State<LeafNodeBuilder> createState() => _LeafNodeBuilderState();
}

class _LeafNodeBuilderState extends State<LeafNodeBuilder> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.node,
      builder: (BuildContext ctx, Widget? child) {
        final NodeComponentBuilder? builder =
            widget.configuration.components.firstWhereOrNull(
          (NodeComponentBuilder b) => b.validate(widget.node),
        );
        if (builder == null) {
          throw StateError(
            'There\'s no a builder configurated '
            'for ${widget.node.runtimeType}(${widget.node.id})',
          );
        }
        Widget child = NodeDraggableBuilder(
          node: widget.node,
          depth: widget.depth,
          builder: builder,
          configuration: widget.configuration,
          child: NodeTargetBuilder(
            builder: builder,
            depth: widget.depth,
            node: widget.node,
            configuration: widget.configuration,
            owner: widget.owner,
          ),
        );

        if (widget.configuration.addRepaintBoundaries) {
          child = RepaintBoundary(child: child);
        }

        final NodeConfiguration? nodeConfig =
            builder.buildConfigurations(ComponentContext(
          depth: widget.depth,
          nodeContext: context,
          node: widget.node,
          details: null,
          extraArgs: widget.configuration.extraArgs,
        ));

        if (nodeConfig == null) {
          return child;
        }

        final Widget? wrapper = nodeConfig.nodeWrapper?.call(
          widget.node,
          context,
          child,
        );
        if (wrapper != null) {
          child = wrapper;
        }

        if (nodeConfig.decoration != null) {
          child = Container(
            decoration: nodeConfig.decoration!,
            clipBehavior: Clip.hardEdge,
            child: child,
          );
        }

        if (!nodeConfig.makeTappable) {
          return child;
        }

        return InkWell(
          onFocusChange: nodeConfig.onFocusChange,
          focusNode: nodeConfig.focusNode,
          focusColor: nodeConfig.focusColor,
          onTap: () => nodeConfig.onTap?.call(context),
          onTapDown: (TapDownDetails details) =>
              nodeConfig.onTapDown?.call(details, context),
          onTapUp: (TapUpDetails details) =>
              nodeConfig.onTapUp?.call(details, context),
          onTapCancel: () => nodeConfig.onTapCancel?.call(context),
          onDoubleTap: nodeConfig.onDoubleTap == null
              ? null
              : () => nodeConfig.onDoubleTap?.call(context),
          onLongPress: nodeConfig.onLongPress == null
              ? null
              : () => nodeConfig.onLongPress?.call(context),
          onSecondaryTap: nodeConfig.onSecondaryTap == null
              ? null
              : () => nodeConfig.onSecondaryTap?.call(context),
          onSecondaryTapUp: nodeConfig.onSecondaryTapUp == null
              ? null
              : (TapUpDetails details) =>
                  nodeConfig.onSecondaryTapUp?.call(details, context),
          onSecondaryTapDown: nodeConfig.onSecondaryTapDown == null
              ? null
              : (TapDownDetails details) =>
                  nodeConfig.onSecondaryTapDown?.call(details, context),
          onSecondaryTapCancel: nodeConfig.onSecondaryTapCancel == null
              ? null
              : () => nodeConfig.onSecondaryTapCancel?.call(context),
          onHover: (bool isHovered) =>
              nodeConfig.onHover?.call(isHovered, context),
          mouseCursor: nodeConfig.mouseCursor,
          hoverDuration: nodeConfig.hoverDuration,
          hoverColor: nodeConfig.hoverColor,
          overlayColor: nodeConfig.overlayColor,
          splashColor: nodeConfig.tapSplashColor,
          splashFactory: nodeConfig.splashFactory,
          borderRadius: nodeConfig.splashBorderRadius,
          customBorder: nodeConfig.customSplashShape,
          canRequestFocus: false,
          excludeFromSemantics: true,
          enableFeedback: true,
          child: wrapper ?? child,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties
        .add(DiagnosticsProperty('${widget.node.runtimeType}', widget.node));
  }
}
