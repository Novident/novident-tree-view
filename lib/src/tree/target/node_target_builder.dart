import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/extensions/cast_nodes.dart';
import 'package:novident_tree_view/src/tree/wrapper/default_nodes_wrapper.dart';
import 'package:vector_math/vector_math_64.dart';

/// [NodeTargetBuilder] handles drag-and-drop operations for tree nodes
class NodeTargetBuilder extends StatefulWidget {
  /// Creates a drag target builder for tree nodes
  const NodeTargetBuilder({
    required this.builder,
    required this.configuration,
    required this.owner,
    required this.depth,
    required this.node,
    required this.index,
    this.child,
    super.key,
  });

  /// Configuration settings for the tree view
  final TreeConfiguration configuration;
  final Widget? child;
  final int depth;
  final Node node;
  final int index;
  final NodeComponentBuilder builder;

  /// The container that owns and manages this node
  final NodeContainer owner;

  @override
  State<NodeTargetBuilder> createState() => _NodeTargetBuilderState();
}

class _NodeTargetBuilderState extends State<NodeTargetBuilder> {
  late NodeDragGestures _gestures;
  late DraggableListener listener = DraggableListener.of(context);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Node>('node', widget.node));
    properties.add(DiagnosticsProperty<Node>('owner', widget.owner));
    properties.add(DiagnosticsProperty<Widget?>('child', widget.child));
    properties.add(DiagnosticsProperty<TreeConfiguration>(
        'configuration', widget.configuration));
    properties.add(DiagnosticsProperty<int>('depth', widget.depth));
    properties.add(
        DiagnosticsProperty<NodeComponentBuilder>('builder', widget.builder));
  }

  @override
  void initState() {
    _gestures = widget.builder.buildDragGestures(
      ComponentContext(
        depth: widget.depth,
        index: widget.index,
        nodeContext: context,
        node: widget.node,
        details: _details,
        marksNeedBuild: () {
          if (context.mounted && mounted) {
            setState(() {});
          }
        },
        wrapWithDragGestures: wrapWithDragAndDropWidgets,
        extraArgs: widget.configuration.extraArgs,
      ),
    );
    super.initState();
  }

  /// Timer used for delayed auto-expansion on hover
  Timer? timer;

  /// Current drag-and-drop operation details
  NovDragAndDropDetails<Node>? __details;
  bool _needsInitializeDragListener = true;

  NovDragAndDropDetails<Node>? get _details => __details;
  set _details(NovDragAndDropDetails<Node>? details) {
    __details = details;
    if (mounted && details != null) {
      DragAndDropDetailsListener.of(context).details.value =
          NodeDragAndDropDetails(
        draggedNode: __details!.draggedNode,
        targetNode: __details!.targetNode,
        inside: __details!.exactPosition() == DragHandlerPosition.into,
      );
    }
  }

  @override
  void dispose() {
    if (mounted) {
      timer?.cancel();
      timer = null;
    }
    super.dispose();
  }

  /// Determines whether a dragged node can be accepted by this target
  bool _onWillAccept(DragTargetDetails<Node> details) {
    _details ??= _getDropDetails(
      details.offset,
      details.data,
      starting: _needsInitializeDragListener,
    );
    return _gestures.onWillAcceptWithDetails(
      _details,
      details,
      widget.node,
      widget.owner,
    );
  }

  /// Calculates precise drop position details during a drag-and-drop operation.
  ///
  /// - [draggedNode] : The node currently being dragged. Must not be the same as the target node.
  /// - [StateError] when:
  ///   - The widget is not attached to the render tree
  ///   - There's no active drag operation (inconsistent state)
  NovDragAndDropDetails<Node>? _getDropDetails(
    Offset pointer,
    Node draggedNode, {
    bool starting = false,
  }) {
    if (!context.mounted || !mounted) {
      return null;
    }
    // Get the render box for coordinate conversions
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;

    // Safety check for widget attachment
    if (!renderBox.attached) {
      throw StateError(
        'The node ${widget.node.runtimeType}(${widget.node.id}) is '
        'not attached into the widgets tree',
      );
    }

    // ## Coordinate Systems Explanation
    //
    // 1. `globalTargetNodeOffset`: Position of this widget in global coordinates
    // 2. `globalDropPosition`: Raw cursor position in global coordinates
    // 3. `targetBounds`: Size and position (at origin) of this widget
    final Vector3 vectorPosition =
        renderBox.getTransformTo(null).getTranslation();
    final Offset offset = Offset(vectorPosition.x, vectorPosition.y);

    // TODO: ahora necesitamos un listener para el actual offset del cursor
    // tal vez podriamos ponerlo como ya parte del DraggableListener
    if (starting && !listener.dragListener.isDragging) {
      _needsInitializeDragListener = false;
      listener.dragListener
        ..draggedNode = draggedNode
        ..targetNode = widget.node
        ..globalPosition = offset;
    }

    // Compose all drop information
    return NovDragAndDropDetails<Node>(
      draggedNode: listener.dragListener.draggedNode ?? draggedNode,
      globalTargetNodeOffset: offset,
      targetNode: widget.node,
      dropPosition: renderBox
          .globalToLocal(listener.dragListener.globalPosition ?? pointer),
      globalDropPosition: listener.dragListener.globalPosition ?? offset,
      targetBounds: Offset.zero & renderBox.size,
    );
  }

  /// Handles drag movement over the target area
  ///
  /// [details]: Information about the current drag operation
  void _onMove(DragTargetDetails<Node> details) {
    _startOrCancelOnHoverExpansion(cancel: true);

    if (listener.dragListener.targetNode != widget.node) {
      listener.dragListener.targetNode = widget.node;
    }

    setState(() {
      _details = _getDropDetails(details.offset, details.data);
    });

    if (details.data.id != widget.node.id) {
      _startOrCancelOnHoverExpansion();
    }
    _gestures.onDragMove?.call(details);
  }

  /// Handles node drop acceptance
  ///
  /// [details]: Information about the dropped node
  void _onAccept(DragTargetDetails<Node> details) {
    _startOrCancelOnHoverExpansion(cancel: true);
    _details ??= _getDropDetails(details.offset, details.data);

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
  /// [data]: The node that was being dragged
  void _onLeave(Node? data) {
    _needsInitializeDragListener = true;

    listener.dragListener.targetNode = null;

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
    if (cancel) {
      timer?.cancel();
      timer = null;
      return;
    }

    // Skip if auto-expansion is disabled or node isn't a container
    if (!widget.configuration.draggableConfigurations.allowAutoExpandOnHover ||
        widget.node is! NodeContainer) {
      return;
    }

    // Don't expand if already expanded
    if (widget.node.castToContainer().isExpanded ||
        (_details != null &&
            _details!.exactPosition() != DragHandlerPosition.into)) {
      return;
    }

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
      index: widget.index,
      node: widget.node,
      extraArgs: widget.configuration.extraArgs,
      wrapWithDragGestures: wrapWithDragAndDropWidgets,
      marksNeedBuild: () {
        if (context.mounted && mounted) {
          setState(() {});
        }
      },
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

    return DragTarget<Node>(
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
        return widget.child ??
            widget.builder.build(
              buildContext(
                rejectedData,
                candidateData,
              ),
            );
      },
    );
  }
}
