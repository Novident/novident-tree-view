import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_view/src/utils/context_util_ext.dart';
import 'package:flutter_tree_view/src/widgets/tree/config/tree_configuration.dart';
import 'package:flutter_tree_view/src/widgets/tree/extension/context_tree_ext.dart';
import '../../controller/drag_node_controller.dart';
import '../../entities/tree_node/composite_tree_node.dart';
import '../../entities/tree_node/leaf_tree_node.dart';
import '../../interfaces/draggable_node.dart' as dg;
import '../../controller/tree_controller.dart';
import '../../entities/tree_node/tree_node.dart';
import '../tree_items/composite_node_item.dart';
import '../tree_items/leaf_node_item.dart';

/// `TreeView` provides a customizable and `scrollable` **list view** to display the nodes
/// managed by a TreeController, with additional support for `drag-and-drop` operations.
class TreeView extends StatefulWidget {
  final TreeConfiguration configuration;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool? primary;
  final Clip? clipBehavior;
  final FocusNode? focusNode;
  const TreeView({
    super.key,
    required this.configuration,
    this.shrinkWrap = true,
    this.scrollController,
    this.primary,
    this.clipBehavior,
    this.focusNode,
  });

  @override
  State<StatefulWidget> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watchTree();
    final dragController = context.watchDrag();
    if (controller.tree.isNotEmpty) {
      return ListView(
        shrinkWrap: widget.shrinkWrap,
        controller: widget.scrollController,
        primary: widget.primary,
        clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
        physics: widget.configuration.physics ?? const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            itemCount: controller.tree.length,
            itemBuilder: (context, index) {
              final TreeNode file = controller.tree.elementAt(index);
              if (file is LeafTreeNode) {
                return LeafTreeNodeItemView(
                  leafNode: file,
                  parent: null,
                  configuration: widget.configuration,
                );
              } else
                return CompositeTreeNodeItemView(
                  parent: null,
                  compositeNode: file as CompositeTreeNode,
                  configuration: widget.configuration,
                  findFirstAncestorParent: () => null,
                );
            },
          ),
          RootTargetToDropSection(
            dragController: dragController,
            configuration: widget.configuration,
            controller: controller,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 30),
          ),
        ],
      );
    } else {
      if (widget.configuration.onDetectEmptyRoot != null) return widget.configuration.onDetectEmptyRoot!;
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomCenter,
            height: 200,
            child: const Text("--|| No nodes yet ||--"),
          ),
        ],
      );
    }
  }
}

class RootTargetToDropSection extends StatelessWidget {
  const RootTargetToDropSection({
    super.key,
    required this.dragController,
    required this.controller,
    required this.configuration,
  });

  final TreeConfiguration configuration;
  final DragNodeController dragController;
  final TreeController controller;

  @override
  Widget build(BuildContext context) {
    final offset = context.globalPaintBounds;
    final Size size = MediaQuery.sizeOf(context);
    return ListenableBuilder(
      listenable: dragController,
      builder: (BuildContext context, Widget? child) {
        if (offset == null) return const SizedBox();
        final bool isDragging = dragController.isDragging;
        if (isDragging && (dragController.offset?.dy ?? offset.dy) >= offset.dy) {
          return DragTarget<TreeNode>(
            onWillAcceptWithDetails: (DragTargetDetails<TreeNode> details) {
              if (details.data is! dg.Draggable) return false;
              if (controller.existInRoot(details.data.id)) return false;
              if (configuration.customDragGestures != null &&
                  configuration.customDragGestures!.customRootOnWillAcceptWithDetails != null) {
                return configuration.customDragGestures!.customRootOnWillAcceptWithDetails!(details);
              }
              return true;
            },
            onAcceptWithDetails: configuration.customDragGestures?.customRootOnAcceptWithDetails ??
                (DragTargetDetails<TreeNode> details) async {
                  controller.insertAtRoot(
                    details.data.copyWith(node: details.data.node.copyWith(level: 0)),
                    removeIfNeeded: true,
                  );
                },
            builder: (BuildContext context, List<TreeNode?> candidateData, List<dynamic> rejectedData) =>
                configuration.rootTargetToDropSection?.call(dragController.object) ??
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    height: size.width * 0.95,
                    width: size.width * 0.95,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
