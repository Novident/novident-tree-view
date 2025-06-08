import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/wrapper/default_nodes_wrapper.dart';
import 'package:provider/provider.dart';

/// Represents the leaf [Node] into the Tree
class LeafNodeBuilder extends StatefulWidget {
  /// The [ContainerTreeNode] item
  final Node node;

  /// The current index of this node;
  final int index;

  /// The owner of this [NodeContainer]
  final NodeContainer owner;

  /// The depth of the current node
  ///
  /// shouldn't be different than the Node level
  final int depth;

  const LeafNodeBuilder({
    required this.node,
    required this.owner,
    required this.depth,
    required this.index,
    super.key,
  });

  @override
  State<LeafNodeBuilder> createState() => _LeafNodeBuilderState();
}

class _LeafNodeBuilderState extends State<LeafNodeBuilder> {
  bool _initStateCalled = false;
  NodeComponentBuilder? _builder;
  late final TreeConfiguration configuration = Provider.of<TreeConfiguration>(context);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('Tree depth', widget.depth));
    properties.add(DiagnosticsProperty('owner', widget.owner));
    properties.add(DiagnosticsProperty('leaf', widget.node));
  }

  @override
  void didChangeDependencies() {
    if (!_initStateCalled) {
      _builder ??= _checkForBuilder();
      _builder!.initState(widget.node, widget.depth);
      _initStateCalled = true;
    }
    _builder?.didChangeDependencies(_buildContext);
    super.didChangeDependencies();
  }

  @override
  didUpdateWidget(covariant LeafNodeBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _builder?.didUpdateWidget(_buildContext, false);

    if (oldWidget.node != widget.node) {
      _builder = null;
    }
  }

  void _markNeedsBuild() {
    if (context.mounted && mounted) {
      setState(() {});
    }
  }

  NodeComponentBuilder get builder {
    _builder ??= _checkForBuilder();
    return _builder!.validate(
      widget.node,
      widget.depth,
    )
        ? _builder!
        : _builder = _checkForBuilder();
  }

  NodeComponentBuilder _checkForBuilder() {
    final NodeComponentBuilder? tempB = configuration.components.firstWhereOrNull(
      (NodeComponentBuilder b) => b.validate(
        widget.node,
        widget.depth,
      ),
    );
    if (tempB == null) {
      throw StateError(
        'No NodeComponentBuilder was '
        'found with correct validate method return '
        'for Node(${widget.node.id.substring(0, 7)})'
        ':'
        '${widget.node}',
      );
    }
    return tempB;
  }

  ComponentContext get _buildContext => ComponentContext(
        depth: widget.depth,
        nodeContext: context,
        wrapWithDragGestures: wrapWithDragAndDropWidgets,
        node: widget.node,
        index: widget.index,
        marksNeedBuild: _markNeedsBuild,
        details: null,
        extraArgs: configuration.extraArgs,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.node,
      builder: (BuildContext ctx, Widget? child) {
        Widget child = NodeDraggableBuilder(
          node: widget.node,
          depth: widget.depth,
          builder: builder,
          index: widget.index,
          configuration: configuration,
          child: NodeTargetBuilder(
            builder: builder,
            depth: widget.depth,
            index: widget.index,
            node: widget.node,
            configuration: configuration,
            owner: widget.owner,
          ),
        );

        final NodeConfiguration? nodeConfig = builder.buildConfigurations(_buildContext);

        if (nodeConfig == null) {
          return child;
        }

        final Widget? wrapper = nodeConfig.nodeWrapper?.call(
          widget.node,
          context,
          child,
        );

        if (nodeConfig.decoration != null) {
          child = Container(
            decoration: nodeConfig.decoration!,
            clipBehavior: Clip.hardEdge,
            child: child,
          );
        }

        if (configuration.addRepaintBoundaries) {
          child = RepaintBoundary(child: child);
        }

        if (!nodeConfig.makeTappable) {
          return child;
        }

        child = InkWell(
          onFocusChange: nodeConfig.onFocusChange,
          focusNode: nodeConfig.focusNode,
          focusColor: nodeConfig.focusColor,
          onTap: () => nodeConfig.onTap?.call(context),
          onTapDown: (TapDownDetails details) =>
              nodeConfig.onTapDown?.call(details, context),
          onTapUp: (TapUpDetails details) => nodeConfig.onTapUp?.call(details, context),
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
              nodeConfig.onHoverInkWell?.call(isHovered, context),
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

        if (wrapper != null) {
          child = wrapper;
        }

        return child;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _builder!.dispose(_buildContext);
  }
}
