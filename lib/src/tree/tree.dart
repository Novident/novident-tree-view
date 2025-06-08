import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart' show Node, NodeContainer;
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:provider/provider.dart';

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

  const TreeView({
    required this.root,
    required this.configuration,
    this.bottomInsets = 30,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  /// Widget displayed when no nodes are found in the tree
  Widget get noNodesFoundWidget =>
      widget.configuration.onDetectEmptyRoot ?? _kDefaultNotFoundWidget;

  @override
  Widget build(BuildContext context) {
    return DragAndDropDetailsListener(
      child: DraggableListener(
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
            addRepaintBoundaries: false,
            addSemanticIndexes: widget
                .configuration.treeListViewConfigurations.addSemanticIndexes,
            addAutomaticKeepAlives: widget.configuration
                .treeListViewConfigurations.addAutomaticKeepAlives,
            physics: widget.configuration.treeListViewConfigurations.physics ??
                const NeverScrollableScrollPhysics(),
            children: <Widget>[
              // Main tree content
              ListenableBuilder(
                listenable: widget.root,
                builder: (BuildContext context, Widget? child) {
                  return ListView.builder(
                    shrinkWrap: widget
                        .configuration.treeListViewConfigurations.shrinkWrap,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    clipBehavior: widget.configuration
                            .treeListViewConfigurations.clipBehavior ??
                        Clip.hardEdge,
                    itemCount: widget.root.isEmpty ? 1 : widget.root.length,
                    reverse:
                        widget.configuration.treeListViewConfigurations.reverse,
                    itemExtent: widget
                        .configuration.treeListViewConfigurations.itemExtent,
                    itemExtentBuilder: widget.configuration
                        .treeListViewConfigurations.itemExtentBuilder,
                    prototypeItem: widget
                        .configuration.treeListViewConfigurations.prototypeItem,
                    findChildIndexCallback: widget.configuration
                        .treeListViewConfigurations.findChildIndexCallback,
                    addAutomaticKeepAlives: widget.configuration
                        .treeListViewConfigurations.addSemanticIndexes,
                    addSemanticIndexes: widget.configuration
                        .treeListViewConfigurations.addSemanticIndexes,
                    cacheExtent: widget
                        .configuration.treeListViewConfigurations.cacheExtent,
                    semanticChildCount: widget.configuration
                        .treeListViewConfigurations.semanticChildCount,
                    dragStartBehavior: widget.configuration
                        .treeListViewConfigurations.dragStartBehavior,
                    keyboardDismissBehavior: widget.configuration
                        .treeListViewConfigurations.keyboardDismissBehavior,
                    restorationId: widget
                        .configuration.treeListViewConfigurations.restorationId,
                    hitTestBehavior: widget.configuration
                        .treeListViewConfigurations.hitTestBehavior,
                    itemBuilder: _itemBuilder,
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

  Widget? _itemBuilder(BuildContext context, int index) {
    if (widget.root.isEmpty) {
      return noNodesFoundWidget;
    }
    final Node node = widget.root.children.elementAt(index);
    // Build appropriate node type
    if (node is! NodeContainer) {
      return LeafNodeBuilder(
        key: ValueKey(node.id),
        node: node,
        index: index,
        depth: 0,
        owner: widget.root,
      );
    } else {
      return ContainerBuilder(
        key: ValueKey(node.id),
        nodeContainer: node,
        index: index,
        depth: 0,
        owner: widget.root,
      );
    }
  }
}

/// Default widget shown when no nodes are present in the tree
Widget get _kDefaultNotFoundWidget => Column(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomCenter,
          height: 200,
          child: const Text(" No nodes yet "),
        ),
      ],
    );
