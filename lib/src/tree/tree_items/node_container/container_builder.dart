import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/tree_items/leaf_node/leaf_node_builder.dart';

/// Represents the [NodeContainer] into the Tree
/// that contains all its children and can be expanded
/// or closed
class ContainerBuilder extends StatefulWidget {
  final int depth;

  /// The [ContainerTreeNode] item
  final NodeContainer nodeContainer;

  /// The owner of this [NodeContainer]
  final NodeContainer owner;

  final TreeConfiguration configuration;

  ContainerBuilder({
    required this.nodeContainer,
    required this.owner,
    required this.configuration,
    required this.depth,
    super.key,
  });

  @override
  State<ContainerBuilder> createState() => _ContainerBuilderState();
}

class _ContainerBuilderState extends State<ContainerBuilder> {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties.add(DiagnosticsProperty('container', widget.nodeContainer));
  }

  @override
  Widget build(BuildContext context) {
    final NodeComponentBuilder? builder =
        widget.configuration.components.firstWhereOrNull(
      (NodeComponentBuilder b) => b.validate(widget.nodeContainer),
    );
    if (builder == null) {
      throw StateError(
        'There\'s no a builder configurated '
        'for ${widget.nodeContainer.runtimeType}(${widget.nodeContainer.id})',
      );
    }
    Widget child = NodeDraggableBuilder(
      node: widget.nodeContainer,
      depth: widget.depth,
      builder: builder,
      configuration: widget.configuration,
      child: NodeTargetBuilder(
        depth: widget.depth,
        builder: builder,
        node: widget.nodeContainer,
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
      node: widget.nodeContainer,
      details: null,
      extraArgs: widget.configuration.extraArgs,
    ));
    if (nodeConfig != null) {
      final Widget? wrapper = nodeConfig.nodeWrapper?.call(
        widget.nodeContainer,
        context,
        child,
      );
      if (wrapper != null) {
        child = wrapper;
      }

      if (nodeConfig.makeTappable) {
        child = InkWell(
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
          child: child,
        );

        if (nodeConfig.decoration != null) {
          child = Container(
            decoration: nodeConfig.decoration!,
            clipBehavior: Clip.hardEdge,
            child: child,
          );
        }
      }
    }

    return ListenableBuilder(
      listenable: widget.nodeContainer,
      builder: (BuildContext ctx, Widget? _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            child,
            builder.buildChildren(
                  ComponentContext(
                    depth: widget.depth,
                    nodeContext: context,
                    node: widget.nodeContainer,
                    details: null,
                  ),
                ) ??
                Visibility(
                  visible: widget.nodeContainer.isExpanded,
                  maintainSize: false,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    itemCount: widget.nodeContainer.children.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Node node =
                          widget.nodeContainer.children.elementAt(index);
                      if (node is! NodeContainer) {
                        return LeafNodeBuilder(
                          depth: widget.depth + 1,
                          node: node,
                          owner: widget.nodeContainer,
                          configuration: widget.configuration,
                        );
                      } else
                        return ContainerBuilder(
                          depth: widget.depth + 1,
                          nodeContainer: node,
                          owner: widget.nodeContainer,
                          configuration: widget.configuration,
                          // there's no parent
                        );
                    },
                  ),
                )
          ],
        );
      },
    );
  }
}
