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
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<int>('Tree depth', widget.depth));
    properties.add(DiagnosticsProperty<NodeContainer>('owner', widget.owner));
    properties.add(
        DiagnosticsProperty<NodeContainer>('container', widget.nodeContainer));
  }

  @override
  Widget build(BuildContext context) {
    final TreeConfiguration configuration =
        Provider.of<TreeConfiguration>(context);
    final NodeComponentBuilder? builder =
        configuration.components.firstWhereOrNull(
      (NodeComponentBuilder b) => b.validate(widget.nodeContainer),
    );
    if (builder == null) {
      throw StateError(
        'There\'s no a builder configurated '
        'for ${widget.nodeContainer.runtimeType}(${widget.nodeContainer.id})',
      );
    }
    final ComponentContext componentContext = ComponentContext(
      depth: widget.depth,
      nodeContext: context,
      wrapWithDragGestures: wrapWithDragAndDropWidgets,
      node: widget.nodeContainer,
      index: widget.index,
      marksNeedBuild: () {
        if (context.mounted && mounted) {
          setState(() {});
        }
      },
      details: null,
      extraArgs: configuration.extraArgs,
    );
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

    if (configuration.addRepaintBoundaries) {
      child = RepaintBoundary(child: child);
    }

    return ListenableBuilder(
      listenable: widget.nodeContainer,
      builder: (BuildContext context, Widget? _) {
        Widget container = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            child,
            builder.buildChildren(
                  componentContext,
                ) ??
                Visibility(
                  visible: widget.nodeContainer.isExpanded,
                  maintainSize: false,
                  maintainState: false,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    shrinkWrap:
                        configuration.treeListViewConfigurations.shrinkWrap,
                    clipBehavior:
                        configuration.treeListViewConfigurations.clipBehavior ??
                            Clip.hardEdge,
                    itemCount: widget.nodeContainer.length,
                    reverse: configuration.treeListViewConfigurations.reverse,
                    itemExtent:
                        configuration.treeListViewConfigurations.itemExtent,
                    itemExtentBuilder: configuration
                        .treeListViewConfigurations.itemExtentBuilder,
                    prototypeItem:
                        configuration.treeListViewConfigurations.prototypeItem,
                    findChildIndexCallback: configuration
                        .treeListViewConfigurations.findChildIndexCallback,
                    addAutomaticKeepAlives: configuration
                        .treeListViewConfigurations.addSemanticIndexes,
                    addSemanticIndexes: configuration
                        .treeListViewConfigurations.addSemanticIndexes,
                    cacheExtent:
                        configuration.treeListViewConfigurations.cacheExtent,
                    semanticChildCount: configuration
                        .treeListViewConfigurations.semanticChildCount,
                    dragStartBehavior: configuration
                        .treeListViewConfigurations.dragStartBehavior,
                    keyboardDismissBehavior: configuration
                        .treeListViewConfigurations.keyboardDismissBehavior,
                    restorationId:
                        configuration.treeListViewConfigurations.restorationId,
                    hitTestBehavior: configuration
                        .treeListViewConfigurations.hitTestBehavior,
                    itemBuilder: (BuildContext context, int index) {
                      final Node node = widget.nodeContainer.elementAt(index);
                      if (node is! NodeContainer) {
                        return LeafNodeBuilder(
                          depth: node.level + 1,
                          node: node,
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
                )
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
}
