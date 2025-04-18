import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart' show Node, NodeContainer;
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/tree/tree_items/leaf_node/leaf_node_builder.dart';
import 'package:novident_tree_view/src/tree/tree_items/node_container/container_builder.dart';
import 'package:provider/provider.dart';

/// A customizable scrollable tree view component with drag-and-drop support
///
/// Displays a hierarchical tree structure using a combination of ListViews
class TreeView extends StatefulWidget {
  /// The root node container of the tree
  final NodeContainer root;

  /// Configuration object for tree behavior and appearance
  final TreeConfiguration configuration;

  /// Bottom padding for the scrollable area
  final double bottomInsets;

  TreeView({
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
    return DraggableListener(
      child: Provider<TreeConfiguration>(
        create: (BuildContext context) => widget.configuration,
        child: ListView(
          shrinkWrap: widget.configuration.treeListViewConfigurations.shrinkWrap,
          controller: widget.configuration.treeListViewConfigurations.scrollController,
          primary: widget.configuration.treeListViewConfigurations.primary,
          clipBehavior: widget.configuration.treeListViewConfigurations.clipBehavior ??
              Clip.hardEdge,
          addRepaintBoundaries: false,
          physics: widget.configuration.treeListViewConfigurations.physics ??
              const NeverScrollableScrollPhysics(),
          children: <Widget>[
            // Main tree content
            ListenableBuilder(
              listenable: widget.root,
              builder: (BuildContext context, Widget? child) {
                if (widget.root.isEmpty) return noNodesFoundWidget;
                return ListView.builder(
                  shrinkWrap: widget.configuration.treeListViewConfigurations.shrinkWrap,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  primary: false,
                  clipBehavior:
                      widget.configuration.treeListViewConfigurations.clipBehavior ??
                          Clip.hardEdge,
                  itemCount: widget.root.length,
                  hitTestBehavior: HitTestBehavior.translucent,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (BuildContext context, int index) {
                    final Node node = widget.root.children.elementAt(index);
                    // Build appropriate node type
                    if (node is! NodeContainer) {
                      return LeafNodeBuilder(
                        node: node,
                        depth: 0,
                        owner: widget.root,
                      );
                    } else {
                      return ContainerBuilder(
                        nodeContainer: node,
                        depth: 0,
                        owner: widget.root,
                      );
                    }
                  },
                );
              },
            ),
            // Bottom padding spacer
            Padding(
              padding: EdgeInsets.only(
                bottom: widget.bottomInsets,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Default widget shown when no nodes are present in the tree
///
/// Used when [TreeConfiguration.onDetectEmptyRoot] is not provided
Widget get _kDefaultNotFoundWidget => Column(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomCenter,
          height: 200,
          child: const Text("--|| No nodes yet ||--"),
        ),
      ],
    );
