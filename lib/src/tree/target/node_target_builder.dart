import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/extensions/cast_nodes.dart';
import 'package:vector_math/vector_math_64.dart';

/// [NodeTargetBuilder] handles drag-and-drop operations for tree nodes
///
/// This widget builds a drag target area around tree nodes and manages:
/// - Drag acceptance validation
/// - Drop position calculations
/// - Hover effects and auto-expansion
/// - Drag-and-drop event handling
class NodeTargetBuilder extends StatefulWidget {
  /// Creates a drag target builder for tree nodes
  ///
  /// [builder]: The target node for drag operations
  /// [configuration]: Tree configuration parameters
  /// [owner]: The container that owns this node
  NodeTargetBuilder({
    required this.builder,
    required this.configuration,
    required this.owner,
    required this.depth,
    required this.node,
    super.key,
  });

  /// Configuration settings for the tree view
  final TreeConfiguration configuration;

  final int depth;
  final NodeComponentBuilder builder;
  final Node node;

  /// The container that owns and manages this node
  final NodeContainer owner;

  @override
  State<NodeTargetBuilder> createState() => _NodeTargetBuilderState();
}

/// The state class for [NodeTargetBuilder] that manages drag-and-drop operations
class _NodeTargetBuilderState extends State<NodeTargetBuilder>
    with TickerProviderStateMixin<NodeTargetBuilder> {
  late NodeDragGestures _gestures;

  @override
  void initState() {
    _gestures = widget.builder.buildGestures(
      ComponentContext(
        depth: widget.depth,
        nodeContext: context,
        node: widget.node,
        details: _details,
        extraArgs: widget.configuration.extraArgs,
      ),
    );
    super.initState();
  }

  /// Timer used for delayed auto-expansion on hover
  Timer? timer = null;

  /// Current drag-and-drop operation details
  NovDragAndDropDetails<Node>? _details;

  @override
  void dispose() {
    // Clean up the timer when the widget is disposed
    if (mounted) {
      timer?.cancel();
      timer = null;
    }
    super.dispose();
  }

  /// Determines whether a dragged node can be accepted by this target
  ///
  /// [gestures]: The drag gesture handlers
  /// [details]: Information about the dragged node
  /// Returns true if the node can be accepted
  bool _onWillAccept(DragTargetDetails<Node> details) {
    return _gestures.onWillAcceptWithDetails(
      _details,
      details,
      widget.node,
      widget.owner,
    );
  }

  /// Calculates drop position details based on current drag operation
  ///
  /// [draggedNode]: The node being dragged
  /// [pointer]: Current pointer position in global coordinates
  /// Returns detailed drop information including position and bounds
  NovDragAndDropDetails<Node> _getDropDetails(
      Node draggedNode, Offset pointer) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    if (!renderBox.attached) {
      throw StateError(
        'The node ${widget.node.runtimeType}(${widget.node.id}) is '
        'not attached into the widgets tree',
      );
    }
    final Vector3 vectorPosition =
        renderBox.getTransformTo(null).getTranslation();
    final Offset offset = Offset(vectorPosition.x, vectorPosition.y);

    return NovDragAndDropDetails<Node>(
      draggedNode: draggedNode,
      globalTargetNodeOffset: offset,
      targetNode: widget.node,
      dropPosition: renderBox.globalToLocal(pointer),
      globalDropPosition: pointer,
      targetBounds: Offset.zero & renderBox.size,
    );
  }

  /// Handles drag movement over the target area
  ///
  /// [gestures]: The drag gesture handlers
  /// [details]: Information about the current drag operation
  void _onMove(DragTargetDetails<Node> details) {
    _startOrCancelOnHoverExpansion(cancel: true);

    // Only handle one draggable at a time
    if (_details != null && details.data != _details!.draggedNode) return;

    setState(() {
      _details = _getDropDetails(details.data, details.offset);
    });

    _startOrCancelOnHoverExpansion();
    _gestures.onDragMove?.call(details);
  }

  /// Handles node drop acceptance
  ///
  /// [gestures]: The drag gesture handlers
  /// [details]: Information about the dropped node
  void _onAccept(DragTargetDetails<Node> details) {
    _startOrCancelOnHoverExpansion(cancel: true);

    if (_details == null || _details!.draggedNode != details.data) return;

    // Notify about the accepted drop
    _gestures.onAcceptWithDetails.call(
      _details!,
      widget.node,
      widget.owner,
    );

    setState(() {
      _details = null;
    });
  }

  /// Handles when a dragged node leaves the target area
  ///
  /// [gestures]: The drag gesture handlers
  /// [data]: The node that was being dragged
  void _onLeave(Node? data) {
    if (_details == null || data == null || _details!.draggedNode != data) {
      return;
    }

    _startOrCancelOnHoverExpansion(cancel: true);

    setState(() {
      _details = null;
    });

    _gestures.onLeave?.call(data);
  }

  @override
  void didUpdateWidget(covariant NodeTargetBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cancel hover expansion if the feature was disabled
    if (!widget.configuration.draggableConfigurations.allowAutoExpandOnHover) {
      _startOrCancelOnHoverExpansion(cancel: true);
    }
  }

  /// Manages the auto-expansion timer for container nodes on hover
  ///
  /// [cancel]: If true, cancels any pending expansion
  void _startOrCancelOnHoverExpansion({bool cancel = false}) {
    // Skip if auto-expansion is disabled or node isn't a container
    if (!widget.configuration.draggableConfigurations.allowAutoExpandOnHover ||
        widget.node is! NodeContainer) return;

    if (cancel) {
      timer?.cancel();
      timer = null;
      return;
    }

    // Don't expand if already expanded
    if (widget.node.castToContainer().isExpanded) return;

    // Start new timer if none exists or current one isn't active
    bool? isActive = timer?.isActive;
    if (timer == null || (isActive != null && !isActive)) {
      timer = Timer(
        Duration(
          milliseconds: widget.configuration.onHoverContainerExpansionDelay,
        ),
        () {
          widget.configuration.onHoverContainer
              ?.call(widget.node.castToContainer());
        },
      );
    }
  }

  ComponentContext buildContext(
    List<dynamic>? rejectedData,
    List<Node?>? candidateData,
  ) {
    return ComponentContext(
      depth: widget.depth,
      nodeContext: context,
      node: widget.node,
      extraArgs: widget.configuration.extraArgs,
      details: candidateData == null
          ? _details
          : _details?.applyData(candidateData, rejectedData!),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Skip drag target if dropping is disabled or node doesn't accept siblings

    if (widget.node is! DragAndDropMixin ||
        (widget.node is DragAndDropMixin &&
            !widget.node.cast<DragAndDropMixin>().isDropTarget()) ||
        !widget.configuration.activateDragAndDropFeature) {
      return widget.builder.build(
        buildContext(
          null,
          null,
        ),
      );
    }

    return Column(
      children: <Widget>[
        DragTarget<Node>(
          onWillAcceptWithDetails: (DragTargetDetails<Node> details) =>
              _onWillAccept(
            details,
          ),
          onAcceptWithDetails: (DragTargetDetails<Node> details) => _onAccept(
            details,
          ),
          onLeave: (Node? data) => _onLeave(
            data,
          ),
          onMove: (DragTargetDetails<Node> details) => _onMove(
            details,
          ),
          builder: (
            BuildContext context,
            List<Node?> candidateData,
            List<dynamic> rejectedData,
          ) {
            return widget.builder.build(buildContext(
              rejectedData,
              candidateData,
            ));
          },
        ),
      ],
    );
  }
}
