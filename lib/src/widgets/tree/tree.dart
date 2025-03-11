import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:flutter_tree_view/src/controller/drag_node_controller.dart';
import 'package:flutter_tree_view/src/extensions/base_controller_helpers.dart';
import 'package:flutter_tree_view/src/widgets/tree/provider/drag_provider.dart';

/// `TreeView` provides a customizable and `scrollable` **list view** to display the nodes
/// managed by a TreeController, with additional support for `drag-and-drop` operations.
class TreeView extends StatefulWidget {
  final TreeController controller;
  final TreeConfiguration configuration;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool? primary;
  final Clip? clipBehavior;
  final FocusNode? focusNode;
  final double bottomInsets;
  const TreeView({
    required this.controller,
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
  @override
  Widget build(BuildContext context) {
    Widget noNodesFoundWidget =
        widget.configuration.onDetectEmptyRoot ?? kDefaultNotFoundWidget;
    return TreeProvider(
      controller: widget.controller,
      child: ListView(
        shrinkWrap: widget.shrinkWrap,
        controller: widget.scrollController,
        primary: widget.primary,
        clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
        physics: widget.configuration.physics ??
            const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ListenableBuilder(
            listenable: widget.controller.root,
            builder: (BuildContext context, Widget? child) {
              if (widget.controller.root.isEmpty) return noNodesFoundWidget;
              if (widget.configuration.buildCustomChildren != null) {
                return widget.configuration.buildCustomChildren!.call(
                  widget.controller.root.copyWith(),
                  List<Node>.unmodifiable(widget.controller.children),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                itemCount: widget.controller.children.length,
                hitTestBehavior: HitTestBehavior.translucent,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (BuildContext context, int index) {
                  Node file = widget.controller.children.elementAt(index);
                  if (file is LeafNode) {
                    return LeafNodeTile(
                      singleNode: file,
                      owner: widget.controller.root,
                      configuration: widget.configuration,
                    );
                  } else
                    return NodeContainerTile(
                      owner: widget.controller.root,
                      nodeContainer: file as NodeContainer,
                      configuration: widget.configuration,
                    );
                },
              );
            },
          ),
          if (widget.configuration.useRootSection)
            RootTargetToDropSection(
              configuration: widget.configuration,
              controller: widget.controller,
            ),
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

class RootTargetToDropSection extends ConsumerStatefulWidget {
  final TreeConfiguration configuration;
  final TreeController controller;

  const RootTargetToDropSection({
    required this.controller,
    required this.configuration,
    super.key,
  });

  @override
  ConsumerState<RootTargetToDropSection> createState() =>
      _RootTargetToDropSectionState();
}

class _RootTargetToDropSectionState
    extends ConsumerState<RootTargetToDropSection> {
  @override
  Widget build(BuildContext context) {
    NodeDragGestures? dragGestures = widget.configuration.rootGestures;
    if (dragGestures == null) return const SizedBox.shrink();
    (Offset, RenderObject)? result = context.globalOffsetOfWidget;
    Offset? offset = result?.$1;
    Size size = MediaQuery.sizeOf(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        bool isDragging = ref.watch(isDraggingANodeProvider);
        DragNodeController dragController =
            ref.watch(dragControllerProviderState);
        double? targetOffset = dragController.offset?.dy;
        if (offset == null || !isDragging || targetOffset == null)
          return const SizedBox.shrink();
        bool isOffsetEffective = targetOffset >= offset.dy;
        if (isOffsetEffective) {
          return DragTarget<Node>(
            onWillAcceptWithDetails: (DragTargetDetails<Node> details) {
              if (details.data is! MakeDraggable) return false;
              if (widget.controller.existInRoot(details.data.id)) return false;
              if (dragGestures.onWillAcceptWithDetails != null) {
                return dragGestures.onWillAcceptWithDetails!(
                  details,
                  widget.controller.root,
                  null,
                  DragHandlerPosition.root,
                );
              }
              return true;
            },
            onMove: (DragTargetDetails<Node> details) {
              ref.read(isDraggingANodeProvider.notifier).state = true;
            },
            onAcceptWithDetails: (DragTargetDetails<Node> details) async {
              if (dragGestures.onAcceptWithDetails != null) {
                return dragGestures.onAcceptWithDetails!(
                  details,
                  widget.controller.root,
                  null,
                  DragHandlerPosition.root,
                );
              }
              widget.controller.insertAtRoot(
                details.data
                    .copyWith(details: details.data.details.copyWith(level: 0)),
                removeIfNeeded: true,
              );
            },
            builder: (BuildContext context, List<Node?> candidateData,
                    List<dynamic> rejectedData) =>
                widget.configuration.rootTargetToDropSection?.call(DragArgs(
                  offset: dragController.offset,
                  node: dragController.node,
                  targetNode: dragController.targetNode,
                )) ??
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    height: size.width * 0.95,
                    width: size.width * 0.95,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
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

final Widget kDefaultNotFoundWidget = Column(
  children: <Widget>[
    Container(
      alignment: Alignment.bottomCenter,
      height: 200,
      child: const Text("--|| No nodes yet ||--"),
    ),
  ],
);
