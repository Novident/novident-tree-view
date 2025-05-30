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
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
  late final TreeConfiguration configuration =
      Provider.of<TreeConfiguration>(context);

  bool get _hasNotifierAttached => widget.nodeContainer.hasNotifiersAttached;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeNotificationsListener();
    });
  }

  @override
  void didChangeDependencies() {
    if (!_initStateCalled) {
      (_builder ??= _checkForBuilder())
          .initState(widget.nodeContainer, widget.depth);
      _initStateCalled = true;
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ContainerBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // we need to avoid initialize notifications when we are not using animated lists
    _builder!.didUpdateWidget(
      _buildContext,
      widget.nodeContainer.hasNotifiersAttached,
    );

    if (_builder!.avoidCacheBuilder) {
      _builder = null;
    }
    if (configuration.useAnimatedLists) {
      if (oldWidget.nodeContainer != widget.nodeContainer &&
          _hasNotifierAttached) {
        oldWidget.nodeContainer.detachNotifier(
          _onChange,
          detachInChildren: false,
        );
      }

      initializeNotificationsListener();
    }
  }

  @override
  void dispose() {
    _builder!.dispose(_buildContext);
    if (_hasNotifierAttached && widget.nodeContainer.hasNotifiersAttached) {
      widget.nodeContainer.detachNotifier(
        _onChange,
        detachInChildren: false,
      );
    }
    super.dispose();
  }

  void initializeNotificationsListener() {
    if (configuration.useAnimatedLists && !_hasNotifierAttached) {
      widget.nodeContainer.attachNotifier(
        _onChange,
        attachToChildren: false,
      );
    }
  }

  void _onChange(NodeChange change) {
    switch (change) {
      case NodeInsertion():
        onInsertInto(change.to, change.index);
      case NodeMoveChange():
        onInsertInto(change.to, change.index);
      case NodeDeletion():
        onRemoveOfThis(change);
      case NodeClear():
        onClear(change);
      default:
        break;
    }
  }

  AnimatedListState? get animatedState => _animatedListKey.currentState;

  //TODO: we need to create a local state of the node
  // to avoid issues with animated lists. Probably
  // we will need to check if the animatedList is active
  // since we don't really need to "cache" the node state
  // because the state of the widget.nodeContainer
  // is updated after the insertItem is executed
  // (it does not find the new item)
  void onInsertInto(Node to, int index) {
    if (to.id == widget.nodeContainer.id) {
      animatedState?.insertItem(index);
    }
  }

  void onRemoveOfThis(NodeDeletion deletion) {
    if (deletion.inNode.id == widget.nodeContainer.id) {
      animatedState?.removeItem(
        deletion.originalPosition,
        (BuildContext context, Animation<double> a) {
          late Widget child;
          if (deletion.newState is! NodeContainer) {
            child = LeafNodeBuilder(
              node: deletion.newState,
              owner: deletion.inNode as NodeContainer,
              depth: widget.depth + 1,
              index: 0,
              ownerAnimatedListKey: _animatedListKey,
            );
          } else {
            child = ContainerBuilder(
              nodeContainer: deletion.newState as NodeContainer,
              owner: deletion.inNode as NodeContainer,
              depth: widget.depth + 1,
              index: 0,
            );
          }
          return configuration.onDeleteAnimationWrapper!(
            a,
            deletion.newState,
            child,
          );
        },
      );
    }
  }

  void onClear(NodeClear clear) {}

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

  //TODO(cathood0): create a separate package to create a custom drawer that makes
  // the same than the current implementation, but, allows infinite horizontal
  // and vertical size (this should fix our issue with the children having no space
  // to be rendered)
  NodeComponentBuilder get builder {
    _builder ??= _checkForBuilder();
    return _builder!.validate(
      widget.nodeContainer,
      widget.depth,
    )
        ? _builder!
        : _builder = _checkForBuilder();
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
        'There\'s no a builder configurated '
        'for ${widget.nodeContainer.runtimeType}(${widget.nodeContainer.id})',
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
        animatedListGlobalKey:
            configuration.useAnimatedLists ? _animatedListKey : null,
      );

  @override
  Widget build(BuildContext context) {
    _cacheChildrenAfterFirstAsyncBuild =
        builder.cacheChildrenAfterFirstAsyncBuild;
    final ComponentContext componentContext = _buildContext;

    Widget child = NodeDraggableBuilder(
      node: widget.nodeContainer,
      depth: widget.depth,
      index: widget.index,
      builder: builder,
      configuration: configuration,
      child: ListenableBuilder(
          listenable: widget.nodeContainer,
          builder: (BuildContext context, Widget? snapshot) {
            return NodeTargetBuilder(
              depth: widget.depth,
              builder: builder,
              animatedListGlobalKey:
                  configuration.useAnimatedLists ? _animatedListKey : null,
              node: widget.nodeContainer,
              index: widget.index,
              configuration: configuration,
              owner: widget.owner,
            );
          }),
    );

    final NodeConfiguration? nodeConfig = builder.buildConfigurations(
      componentContext,
    );

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

    return ListenableBuilder(
      listenable: widget.nodeContainer,
      builder: (BuildContext context, Widget? _) {
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
              Visibility(
                  visible: widget.nodeContainer.isExpanded,
                  child: _isFirstChildrenBuild
                      ? _buildAsyncChildrenWidgets(
                          componentContext,
                          configuration,
                          builder,
                        )
                      : _buildDefaultChildrenWidgets(configuration, builder)),
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
      },
    );
  }

  void _markNeedsBuild() {
    if (context.mounted && mounted) {
      if (_builder!.avoidCacheBuilder) {
        _builder = null;
      }
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
      child: configuration.useAnimatedLists
          ? AnimatedList(
              key: _animatedListKey,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              shrinkWrap: configuration.treeListViewConfigurations.shrinkWrap,
              clipBehavior:
                  configuration.treeListViewConfigurations.clipBehavior ??
                      Clip.hardEdge,
              reverse: configuration.treeListViewConfigurations.reverse,
              initialItemCount: widget.nodeContainer.length,
              itemBuilder: (
                BuildContext context,
                int index,
                Animation<double> animation,
              ) {
                final Node node = widget.nodeContainer.elementAt(index);
                late Widget child;
                if (node is! NodeContainer) {
                  child = LeafNodeBuilder(
                    depth: node.level + 1,
                    node: node,
                    ownerAnimatedListKey: configuration.useAnimatedLists
                        ? _animatedListKey
                        : null,
                    index: index,
                    owner: widget.nodeContainer,
                  );
                } else {
                  child = ContainerBuilder(
                    depth: node.level + 1,
                    index: index,
                    // the owner is this container
                    owner: widget.nodeContainer,
                    // the sub node
                    nodeContainer: node,
                  );
                }
                return configuration.animatedWrapper!(animation, node, child);
              },
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              shrinkWrap: configuration.treeListViewConfigurations.shrinkWrap,
              clipBehavior:
                  configuration.treeListViewConfigurations.clipBehavior ??
                      Clip.hardEdge,
              reverse: configuration.treeListViewConfigurations.reverse,
              itemExtent: configuration.treeListViewConfigurations.itemExtent,
              itemExtentBuilder:
                  configuration.treeListViewConfigurations.itemExtentBuilder,
              prototypeItem:
                  configuration.treeListViewConfigurations.prototypeItem,
              findChildIndexCallback: configuration
                  .treeListViewConfigurations.findChildIndexCallback,
              addAutomaticKeepAlives:
                  configuration.treeListViewConfigurations.addSemanticIndexes,
              addSemanticIndexes:
                  configuration.treeListViewConfigurations.addSemanticIndexes,
              cacheExtent: configuration.treeListViewConfigurations.cacheExtent,
              semanticChildCount:
                  configuration.treeListViewConfigurations.semanticChildCount,
              dragStartBehavior:
                  configuration.treeListViewConfigurations.dragStartBehavior,
              keyboardDismissBehavior: configuration
                  .treeListViewConfigurations.keyboardDismissBehavior,
              restorationId:
                  configuration.treeListViewConfigurations.restorationId,
              hitTestBehavior:
                  configuration.treeListViewConfigurations.hitTestBehavior,
              itemCount: widget.nodeContainer.length,
              itemBuilder: (BuildContext context, int index) {
                final Node node = widget.nodeContainer.elementAt(index);
                if (node is! NodeContainer) {
                  return LeafNodeBuilder(
                    depth: node.level + 1,
                    node: node,
                    ownerAnimatedListKey: configuration.useAnimatedLists
                        ? _animatedListKey
                        : null,
                    index: index,
                    owner: widget.nodeContainer,
                  );
                } else {
                  return ContainerBuilder(
                    depth: node.level + 1,
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
