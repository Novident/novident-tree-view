import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart' show Node, NodeContainer;
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';

/// A customizable scrollable tree view component with drag-and-drop support
///
/// Displays a hierarchical tree structure using a combination of ListViews
@immutable
final class TreeView extends StatefulWidget {
  /// The root node container of the tree
  final NodeContainer root;

  /// Configuration object for tree behavior and appearance
  final TreeConfiguration configuration;

  /// Bottom padding for the scrollable area
  final double bottomInsets;

  /// Custom [AutoScrollerService] implementations to allow making
  /// a service for auto-scrolling with different behaviors
  final AutoScrollerService Function(ScrollableState)? customScrollableService;

  const TreeView({
    required this.root,
    required this.configuration,
    this.bottomInsets = 30,
    this.customScrollableService,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  /// Persistent drag state shared across tree rebuilds.
  final DragListener _dragListener = DragListener();
  ScrollableState? scrollableState;
  AutoScrollerService? autoScroller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty.lazy(
      'dragListenerState',
      () => _dragListener,
    ));
    super.debugFillProperties(properties);
  }

  /// Widget displayed when no nodes are found in the tree
  Widget? Function(BuildContext) get noNodesFoundWidget =>
      widget.configuration.emptyPlaceholder ?? _kDefaultNotFoundWidget;

  void updateAutoScroller(
    ScrollableState scrollableState,
  ) {
    if (this.scrollableState != scrollableState) {
      autoScroller?.stopAutoScroll();
      late AutoScrollerService scroller;
      scroller = widget.customScrollableService?.call(scrollableState) ??
          AutoScroller(
            scrollableState,
            onScrollViewScrolled: () => _onScrollViewScrolled(scroller),
          );
      autoScroller = scroller;
      this.scrollableState = scrollableState;
    }
  }

  void _onScrollViewScrolled(AutoScrollerService scroller) {
    if (!UniversalPlatform.isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (autoScroller == scroller) {
          scroller.continueToAutoScroll();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragAndDropDetailsListener(
      child: DraggableListener(
        listener: _dragListener,
        child: Provider<TreeConfiguration>(
          create: (BuildContext context) => widget.configuration,
          child: ListView(
            shrinkWrap:
                widget.configuration.treeListViewConfigurations.shrinkWrap,
            controller: widget
                .configuration.treeListViewConfigurations.scrollController,
            primary: widget.configuration.treeListViewConfigurations.primary,
            clipBehavior:
                widget.configuration.treeListViewConfigurations.clipBehavior ??
                    Clip.hardEdge,
            addRepaintBoundaries: true,
            addAutomaticKeepAlives: false,
            physics: widget.configuration.treeListViewConfigurations.physics ??
                const NeverScrollableScrollPhysics(),
            children: <Widget>[
              // Main tree content
              Builder(
                builder: (ctx) {
                  // We can use manually external scrollables
                  //
                  // Or use the main ListView Scrollable
                  final scrollable =
                      Scrollable.maybeOf(context) ?? Scrollable.maybeOf(ctx);
                  if (scrollable != null) updateAutoScroller(scrollable);
                  return Provider<AutoScrollerService?>(
                    create: (BuildContext context) => autoScroller,
                    child: TreeListView(
                      root: widget.root,
                      noNodesFoundWidget: noNodesFoundWidget,
                      configuration: widget.configuration,
                    ),
                  );
                },
              ),
              // Bottom padding spacer
              Padding(
                padding: EdgeInsets.only(
                  bottom: widget.bottomInsets,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@internal
class TreeListView extends StatelessWidget {
  const TreeListView({
    super.key,
    required this.configuration,
    required this.root,
    required this.noNodesFoundWidget,
  });

  final TreeConfiguration configuration;
  final NodeContainer root;
  final Widget? Function(BuildContext) noNodesFoundWidget;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: root,
      builder: (BuildContext context, Widget? child) => ListView.builder(
        shrinkWrap: configuration.treeListViewConfigurations.shrinkWrap,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        addSemanticIndexes:
            configuration.treeListViewConfigurations.addSemanticIndexes,
        clipBehavior: configuration.treeListViewConfigurations.clipBehavior ??
            Clip.hardEdge,
        itemCount: root.isEmpty ? 1 : root.length,
        reverse: configuration.treeListViewConfigurations.reverse,
        itemExtent: configuration.treeListViewConfigurations.itemExtent,
        itemExtentBuilder:
            configuration.treeListViewConfigurations.itemExtentBuilder,
        prototypeItem: configuration.treeListViewConfigurations.prototypeItem,
        findChildIndexCallback:
            configuration.treeListViewConfigurations.findChildIndexCallback,
        addAutomaticKeepAlives: false,
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
        itemBuilder: _itemBuilder,
      ),
    );
  }

  Widget? _itemBuilder(BuildContext context, int index) {
    if (root.isEmpty) {
      return noNodesFoundWidget(context) ?? const SizedBox.shrink();
    }
    final Node node = root.children.elementAt(index);
    // Build appropriate node type
    if (node is! NodeContainer) {
      return LeafNodeBuilder(
        key: ValueKey(node.id),
        node: node,
        index: index,
        depth: 0,
        owner: root,
      );
    } else {
      return ContainerBuilder(
        key: ValueKey(node.id),
        nodeContainer: node,
        index: index,
        depth: 0,
        owner: root,
      );
    }
  }
}

/// Default widget shown when no nodes are present in the tree
Widget _kDefaultNotFoundWidget(BuildContext context) => Column(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomCenter,
          height: 200,
          child: const Text(" No nodes yet "),
        ),
      ],
    );
