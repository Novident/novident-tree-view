import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

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
  /// [node]: The target node for drag operations
  /// [configuration]: Tree configuration parameters
  /// [owner]: The container that owns this node
  NodeTargetBuilder({
    required this.node,
    required this.configuration,
    required this.owner,
    super.key,
  }) : assert(owner.isChildrenContainer,
            'The owner must be a children container');

  /// Configuration settings for the tree view
  final TreeConfiguration configuration;

  /// The node associated with this drag target
  final Node node;

  /// The container that owns and manages this node
  final Node owner;

  @override
  State<NodeTargetBuilder> createState() => _NodeTargetBuilderState();
}

/// The state class for [NodeTargetBuilder] that manages drag-and-drop operations
class _NodeTargetBuilderState extends State<NodeTargetBuilder>
    with TickerProviderStateMixin<NodeTargetBuilder> {
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
  bool _onWillAccept(
      NodeDragGestures gestures, DragTargetDetails<Node> details) {
    return gestures.onWillAcceptWithDetails(
      _details,
      details,
      widget.node.isChildrenContainer ? widget.node : widget.owner,
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

    return NovDragAndDropDetails<Node>(
      draggedNode: draggedNode,
      targetNode: widget.node,
      dropPosition: renderBox.globalToLocal(pointer),
      targetBounds: Offset.zero & renderBox.size,
    );
  }

  /// Handles drag movement over the target area
  ///
  /// [gestures]: The drag gesture handlers
  /// [details]: Information about the current drag operation
  void _onMove(NodeDragGestures gestures, DragTargetDetails<Node> details) {
    _startOrCancelOnHoverExpansion(cancel: true);

    // Only handle one draggable at a time
    if (_details != null && details.data != _details!.draggedNode) return;

    setState(() {
      _details = _getDropDetails(details.data, details.offset);
    });

    _startOrCancelOnHoverExpansion();
    gestures.onDragMove?.call(details);
  }

  /// Handles node drop acceptance
  ///
  /// [gestures]: The drag gesture handlers
  /// [details]: Information about the dropped node
  void _onAccept(NodeDragGestures gestures, DragTargetDetails<Node> details) {
    _startOrCancelOnHoverExpansion(cancel: true);

    if (_details == null || _details!.draggedNode != details.data) return;

    // Determine drop position relative to target node
    final DragHandlerPosition position =
        _details!.mapDropPosition<DragHandlerPosition>(
      whenAbove: () => DragHandlerPosition.above,
      whenInside: () => DragHandlerPosition.into,
      whenBelow: () => DragHandlerPosition.below,
    );

    // Notify about the accepted drop
    gestures.onAcceptWithDetails.call(
      _details!,
      widget.owner,
      position,
    );

    setState(() {
      _details = null;
    });
  }

  /// Handles when a dragged node leaves the target area
  ///
  /// [gestures]: The drag gesture handlers
  /// [data]: The node that was being dragged
  void _onLeave(NodeDragGestures gestures, Node? data) {
    if (_details == null || data == null || _details!.draggedNode != data) {
      return;
    }

    _startOrCancelOnHoverExpansion(cancel: true);

    setState(() {
      _details = null;
    });

    gestures.onLeave?.call(data);
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
        !widget.node.isChildrenContainer) return;

    if (cancel) {
      timer?.cancel();
      timer = null;
      return;
    }

    // Don't expand if already expanded
    if (widget.node.isExpanded) return;

    // Start new timer if none exists or current one isn't active
    bool? isActive = timer?.isActive;
    if (timer == null || (isActive != null && !isActive)) {
      timer = Timer(
        Duration(
          milliseconds: widget.configuration.onHoverContainerExpansionDelay,
        ),
        () {
          widget.configuration.onHoverContainer?.call(widget.node);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skip drag target if dropping is disabled or node doesn't accept siblings
    if (!widget.node.isDropTarget() ||
        !widget.configuration.activateDragAndDropFeature) {
      return widget.configuration.nodeBuilder(widget.node, _details);
    }

    NodeDragGestures? dragGestures =
        widget.configuration.nodeDragGestures(widget.node);

    return Column(
      children: <Widget>[
        DragTarget<Node>(
          onWillAcceptWithDetails: (DragTargetDetails<Node> details) =>
              _onWillAccept(
            dragGestures,
            details,
          ),
          onAcceptWithDetails: (DragTargetDetails<Node> details) => _onAccept(
            dragGestures,
            details,
          ),
          onLeave: (Node? data) => _onLeave(
            dragGestures,
            data,
          ),
          onMove: (DragTargetDetails<Node> details) => _onMove(
            dragGestures,
            details,
          ),
          builder: (
            BuildContext context,
            List<Node?> candidateData,
            List<dynamic> rejectedData,
          ) {
            return widget.configuration.nodeBuilder(
              widget.node,
              context,
              _details?.applyData(
                candidateData,
                rejectedData,
              ),
            );
          },
        ),
      ],
    );
  }
}
