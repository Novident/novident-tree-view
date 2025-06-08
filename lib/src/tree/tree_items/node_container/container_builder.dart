import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/wrapper/default_nodes_wrapper.dart';
import 'package:provider/provider.dart';

/// Represents the [NodeContainer] into the Tree
/// that contains all its children and can be expanded
/// or closed
class ContainerBuilder extends StatefulWidget {
  /// The [ContainerTreeNode] item
  final NodeContainer nodeContainer;

  /// The owner of this [NodeContainer]
  final NodeContainer owner;

  /// The depth of the current node
  ///
  /// shouldn't be different than the Node level
  final int depth;
  final int index;

  const ContainerBuilder({
    required this.nodeContainer,
    required this.owner,
    required this.depth,
    required this.index,
    super.key,
  });

  @override
  State<ContainerBuilder> createState() => _ContainerBuilderState();
}

class _ContainerBuilderState extends State<ContainerBuilder> {
  bool _cacheChildrenAfterFirstAsyncBuild = false;
  bool _isFirstChildrenBuild = true;
  bool _initStateCalled = false;
  NodeComponentBuilder? _builder;
  late final TreeConfiguration configuration =
      Provider.of<TreeConfiguration>(context);

  @override
  initState() {
    super.initState();
    widget.nodeContainer.addListener(_markNeedsBuild);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<int>('Tree depth', widget.depth));
    properties.add(DiagnosticsProperty<NodeContainer>('owner', widget.owner));
    properties.add(
        DiagnosticsProperty<NodeContainer>('container', widget.nodeContainer));
    properties.add(DiagnosticsProperty<bool>(
        'isFirstChildrenBuild', _isFirstChildrenBuild));
    properties.add(DiagnosticsProperty<bool>(
        'willCacheChildrenAfterFirstAsyncBuild',
        _cacheChildrenAfterFirstAsyncBuild));
  }

  @override
  void didChangeDependencies() {
    if (!_initStateCalled) {
      _builder ??= _checkForBuilder();
      _builder!.initState(widget.nodeContainer, widget.depth);
      _initStateCalled = true;
    }
    _builder?.didChangeDependencies(_buildContext);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ContainerBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.nodeContainer.removeListener(_markNeedsBuild);
    widget.nodeContainer.addListener(_markNeedsBuild);

    // we need to avoid initialize notifications when we are not using animated lists
    _builder?.didUpdateWidget(
      _buildContext,
      widget.nodeContainer.hasNotifiersAttached,
    );

    if (oldWidget.nodeContainer != widget.nodeContainer) {
      _builder = null;
    }
  }

  NodeComponentBuilder get builder {
    _builder ??= _checkForBuilder();
    // if the current builder is cached, as now
    // is not validating the current one, we need
    // to reload it again to avoid bad builder
    // selection
    if (!_builder!.validate(
      widget.nodeContainer,
      widget.depth,
    )) {
      _builder = _checkForBuilder();
    }
    return _builder!;
  }

  NodeComponentBuilder _checkForBuilder() {
    final NodeComponentBuilder? tempB =
        configuration.components.firstWhereOrNull(
      (NodeComponentBuilder b) => b.validate(
        widget.nodeContainer,
        widget.depth,
      ),
    );
    if (tempB == null) {
      throw StateError(
        'No NodeComponentBuilder was '
        'found with correct validate method return '
        'for NodeContainer(${widget.nodeContainer.id.substring(0, 7)})'
        ':'
        '${widget.nodeContainer}',
      );
    }
    return tempB;
  }

  ComponentContext get _buildContext => ComponentContext(
        depth: widget.depth,
        nodeContext: context,
        wrapWithDragGestures: wrapWithDragAndDropWidgets,
        node: widget.nodeContainer,
        index: widget.index,
        marksNeedBuild: _markNeedsBuild,
        details: null,
        extraArgs: context.mounted
            ? configuration.extraArgs
            : const <String, dynamic>{},
      );

  @override
  Widget build(BuildContext context) {
    _cacheChildrenAfterFirstAsyncBuild =
        builder.cacheChildrenAfterFirstAsyncBuild;
    ComponentContext componentContext = _buildContext;
    Widget child = NodeDraggableBuilder(
      node: widget.nodeContainer,
      depth: widget.depth,
      index: widget.index,
      builder: builder,
      configuration: configuration,
      child: NodeTargetBuilder(
        depth: widget.depth,
        builder: builder,
        node: widget.nodeContainer,
        index: widget.index,
        configuration: configuration,
        owner: widget.owner,
      ),
    );

    final NodeConfiguration? nodeConfig =
        builder.buildConfigurations(componentContext);

    if (nodeConfig != null) {
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

    if (configuration.addRepaintBoundaries) {
      child = RepaintBoundary(child: child);
    }

    final bool needsAsync = builder.useAsyncBuild;

    _cacheChildrenAfterFirstAsyncBuild =
        builder.cacheChildrenAfterFirstAsyncBuild;
    _isFirstChildrenBuild =
        _cacheChildrenAfterFirstAsyncBuild ? _isFirstChildrenBuild : true;
    Widget container = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        child,
        if (!needsAsync)
          builder.buildChildren(
                componentContext,
              ) ??
              _buildDefaultChildrenWidgets(configuration, builder),
        if (needsAsync)
          _isFirstChildrenBuild
              ? _buildAsyncChildrenWidgets(
                  componentContext,
                  configuration,
                  builder,
                )
              : _buildDefaultChildrenWidgets(configuration, builder),
      ],
    );

    final Widget? wrapper = nodeConfig?.nodeWrapper?.call(
      widget.nodeContainer,
      context,
      container,
    );

    if (wrapper != null) {
      container = wrapper;
    }

    return container;
  }

  @override
  void dispose() {
    _builder!.dispose(_buildContext);
    widget.nodeContainer.removeListener(_markNeedsBuild);
    super.dispose();
  }

  void _markNeedsBuild() {
    if (context.mounted && mounted) {
      setState(() {});
    }
  }

  Widget _buildAsyncChildrenWidgets(
    ComponentContext componentContext,
    TreeConfiguration configuration,
    NodeComponentBuilder builder,
  ) {
    return FutureBuilder<List<Widget>?>(
      future: builder.buildChildrenAsync(componentContext),
      builder: (BuildContext ctx, AsyncSnapshot<List<Widget>?> value) {
        if (value.hasError) {
          return builder.buildChildrenAsyncError(
                  componentContext, value.stackTrace, value.error!) ??
              const SizedBox.shrink();
        }
        if (!value.hasData) {
          return builder.buildChildrenAsyncPlaceholder(componentContext) ??
              const SizedBox.shrink();
        }
        if (_cacheChildrenAfterFirstAsyncBuild && _isFirstChildrenBuild) {
          _isFirstChildrenBuild = false;
        }
        final List<Widget> list = value.data!;
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          shrinkWrap: configuration.treeListViewConfigurations.shrinkWrap,
          clipBehavior: configuration.treeListViewConfigurations.clipBehavior ??
              Clip.hardEdge,
          reverse: configuration.treeListViewConfigurations.reverse,
          itemExtent: configuration.treeListViewConfigurations.itemExtent,
          itemExtentBuilder:
              configuration.treeListViewConfigurations.itemExtentBuilder,
          prototypeItem: configuration.treeListViewConfigurations.prototypeItem,
          findChildIndexCallback:
              configuration.treeListViewConfigurations.findChildIndexCallback,
          addAutomaticKeepAlives:
              configuration.treeListViewConfigurations.addSemanticIndexes,
          addSemanticIndexes:
              configuration.treeListViewConfigurations.addSemanticIndexes,
          cacheExtent: configuration.treeListViewConfigurations.cacheExtent,
          semanticChildCount:
              configuration.treeListViewConfigurations.semanticChildCount,
          dragStartBehavior:
              configuration.treeListViewConfigurations.dragStartBehavior,
          keyboardDismissBehavior:
              configuration.treeListViewConfigurations.keyboardDismissBehavior,
          restorationId: configuration.treeListViewConfigurations.restorationId,
          hitTestBehavior:
              configuration.treeListViewConfigurations.hitTestBehavior,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final Widget node = list.elementAt(index);
            return node;
          },
        );
      },
    );
  }

  Widget _buildDefaultChildrenWidgets(
    TreeConfiguration configuration,
    NodeComponentBuilder builder,
  ) {
    return Visibility(
      visible: widget.nodeContainer.isExpanded,
      maintainSize: false,
      maintainState: false,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        shrinkWrap: configuration.treeListViewConfigurations.shrinkWrap,
        clipBehavior: configuration.treeListViewConfigurations.clipBehavior ??
            Clip.hardEdge,
        hitTestBehavior:
            configuration.treeListViewConfigurations.hitTestBehavior,
        itemCount: widget.nodeContainer.length,
        itemBuilder: (BuildContext context, int index) {
          final Node node = widget.nodeContainer.elementAt(index);
          if (node is! NodeContainer) {
            return LeafNodeBuilder(
              key: ValueKey(node.id),
              depth: node.childrenLevel,
              node: node,
              index: index,
              owner: widget.nodeContainer,
            );
          } else {
            return ContainerBuilder(
              key: ValueKey(node.id),
              depth: node.childrenLevel,
              index: index,
              // the owner is this container
              owner: widget.nodeContainer,
              // the sub node
              nodeContainer: node,
            );
          }
        },
      ),
    );
  }
}
