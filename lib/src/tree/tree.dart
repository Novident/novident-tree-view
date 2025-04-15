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

  /// Controller for the main scroll view
  final ScrollController? scrollController;

  /// Whether the list should shrink-wrap its contents
  final bool shrinkWrap;

  /// Whether this is the primary scroll view
  final bool? primary;

  /// Content clipping behavior
  final Clip? clipBehavior;

  /// Focus node for keyboard interactions
  final FocusNode? focusNode;

  /// Bottom padding for the scrollable area
  final double bottomInsets;

  /// Creates a tree view component
  ///
  /// Required parameters:
  /// [root]: Root node container of the tree
  /// [configuration]: Tree behavior and styling configuration
  ///
  /// Optional parameters:
  /// [bottomInsets]: Bottom padding (default: 30)
  /// [shrinkWrap]: Whether to shrink-wrap content (default: true)
  /// [scrollController]: External scroll controller
  /// [primary]: Primary scroll view flag
  /// [clipBehavior]: Content clipping strategy
  /// [focusNode]: Keyboard focus control
  TreeView({
    required this.root,
    required this.configuration,
    this.bottomInsets = 30,
    this.shrinkWrap = true,
    this.scrollController,
    this.primary,
    this.clipBehavior,
    this.focusNode,
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
    return Provider<TreeConfiguration>(
      create: (BuildContext context) => widget.configuration,
      child: ListView(
        shrinkWrap: widget.shrinkWrap,
        controller: widget.scrollController,
        primary: widget.primary,
        clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
        physics: widget.configuration.physics ??
            const NeverScrollableScrollPhysics(),
        children: <Widget>[
          // Main tree content
          ListenableBuilder(
            listenable: widget.root,
            builder: (BuildContext context, Widget? child) {
              if (widget.root.isEmpty) return noNodesFoundWidget;
              return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                clipBehavior: Clip.hardEdge,
                itemCount: widget.root.children.length,
                hitTestBehavior: HitTestBehavior.translucent,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (BuildContext context, int index) {
                  final Node node = widget.root.children.elementAt(index);
                  // Build appropriate node type
                  if (node is! NodeContainer) {
                    return LeafNodeBuilder(
                      node: node,
                      depth: 0,
                      owner: widget.root,
                      configuration: widget.configuration,
                    );
                  } else {
                    return ContainerBuilder(
                      nodeContainer: node,
                      depth: 0,
                      owner: widget.root,
                      configuration: widget.configuration,
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
