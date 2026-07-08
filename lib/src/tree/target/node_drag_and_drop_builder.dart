import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:novident_tree_view/src/extensions/cast_nodes.dart';
import 'package:vector_math/vector_math_64.dart';

/// Unified widget that handles both drag initiation and drop acceptance
/// for tree nodes in a single [StatefulWidget].
///
/// Previously, [NodeDraggableBuilder] and [NodeTargetBuilder] were separate
/// widgets that nested — causing a frame delay between [DraggableListener]
/// updates and [DragTarget] reactions, plus duplicate [NodeDragGestures]
/// construction.
///
/// By unifying them, both halves share the same state, the same
/// [DraggableListener] access, and a single [NodeDragGestures] instance.
@immutable
class NodeDragAndDropBuilder extends StatefulWidget {
  const NodeDragAndDropBuilder({
    required this.node,
    required this.builder,
    required this.configuration,
    required this.depth,
    required this.index,
    required this.owner,
    this.child,
    super.key,
  });

  final Node node;
  final NodeComponentBuilder builder;
  final TreeConfiguration configuration;
  final int depth;
  final int index;

  /// The container that owns and manages this node (used by drop logic).
  final NodeContainer owner;

  /// Optional widget to display instead of calling [builder.build].
  ///
  /// When null, [NodeComponentBuilder.build] is invoked with the current
  /// [ComponentContext].
  final Widget? child;

  @override
  State<NodeDragAndDropBuilder> createState() => _NodeDragAndDropBuilderState();
}

class _NodeDragAndDropBuilderState extends State<NodeDragAndDropBuilder>
    with AutomaticKeepAliveClientMixin {
  // ── Drag gestures ──
  late NodeDragGestures _gestures;

  // ── Inherited listeners ──
  late final DraggableListener _dragListener = DraggableListener.of(context);

  // ── Drop details ──
  NovDragAndDropDetails<Node>? __details;
  bool _needsInitializeDragListener = true;

  NovDragAndDropDetails<Node>? get _details => __details;
  set _details(NovDragAndDropDetails<Node>? details) {
    __details = details;
    if (details != null) {
      DragAndDropDetailsListener.of(context).details.value =
          NodeDragAndDropDetails(
        draggedNode: __details!.draggedNode,
        targetNode: __details!.targetNode,
        inside: __details!.exactPosition() == DragHandlerPosition.into,
      );
    }
  }

  // ── Dragging state ──
  bool get isDragging => _isDragging;
  bool _isDragging = false;

  @override
  bool get wantKeepAlive => _isDragging;

  set isDragging(bool value) {
    if (value == _isDragging) return;
    if (context.mounted && mounted) {
      setState(() {
        _isDragging = value;
        updateKeepAlive();
      });
    } else {
      _isDragging = value;
    }
  }

  // ── Cursor tracking ──
  Offset? __inactiveCursorOffset;

  Offset? get _inactiveCursorOffset => __inactiveCursorOffset;

  set _inactiveCursorOffset(Offset? offset) {
    __inactiveCursorOffset = offset;
    _dragListener.dragListener.userPosition = __inactiveCursorOffset;
  }

  // ── Auto-expand timer ──
  Timer? _timer;

  // ── Lifecycle ──

  @override
  void initState() {
    super.initState();
    _gestures = _buildGestures();
  }

  NodeDragGestures _buildGestures() {
    return widget.builder.buildDragGestures(
      ComponentContext(
        depth: widget.depth,
        index: widget.index,
        nodeContext: context,
        node: widget.node,
        details: _details,
        marksNeedBuild: _markNeedsBuild,
        wrapWithDragGestures: _wrapWithDragAndDrop,
        extraArgs: widget.configuration.extraArgs,
      ),
    );
  }

  @override
  void dispose() {
    isDragging = false;
    if (mounted) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NodeDragAndDropBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget
            .configuration.draggableConfigurations.allowAutoExpandOnHover !=
        widget.configuration.draggableConfigurations.allowAutoExpandOnHover) {
      if (!widget
          .configuration.draggableConfigurations.allowAutoExpandOnHover) {
        _cancelHoverExpansion();
      }
    }
  }

  void _markNeedsBuild() {
    if (context.mounted && mounted) {
      setState(() {});
    }
  }

  // ── Component context builders ──

  ComponentContext _buildContext([
    List<dynamic>? rejectedData,
    List<Node?>? candidateData,
  ]) {
    return ComponentContext(
      depth: widget.depth,
      index: widget.index,
      nodeContext: context,
      node: widget.node,
      details: candidateData == null
          ? _details
          : _details?.applyData(candidateData, rejectedData!),
      marksNeedBuild: _markNeedsBuild,
      wrapWithDragGestures: _wrapWithDragAndDrop,
      extraArgs: widget.configuration.extraArgs,
    );
  }

  // Re-entrant guard to avoid infinite recursion in wrapWithDragAndDropWidgets.
  static Widget _wrapWithDragAndDrop(
    ComponentContext context,
    NodeComponentBuilder builder,
    Widget child,
    bool wrapWithListenableBuilder,
  ) {
    // When called from within our own build, just return the child as-is.
    // The wrapping is already handled at the top level.
    if (wrapWithListenableBuilder) {
      return ListenableBuilder(
        listenable: context.node,
        builder: (_, __) => child,
      );
    }
    return child;
  }

  // ── Drag event handlers ──

  void _onDragStarted() {
    isDragging = true;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset cursorPosition = renderBox.localToGlobal(Offset.zero);
    _dragListener.dragListener
      ..globalPosition = cursorPosition
      ..localPosition = renderBox.globalToLocal(cursorPosition)
      ..targetNode = widget.node
      ..userPosition = _inactiveCursorOffset
      ..draggedNode = widget.node;
    _gestures.onDragStart?.call(cursorPosition, widget.node);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragListener.dragListener
      ..globalPosition = details.globalPosition
      ..localPosition = details.localPosition
      ..userPosition = _inactiveCursorOffset
      ..draggedNode = widget.node;
    _gestures.onDragUpdate?.call(details);
  }

  void _onDraggableCanceled(Velocity velocity, Offset point) {
    _endDrag();
    _dragListener.dragListener
      ..globalPosition = null
      ..localPosition = null
      ..userPosition = _inactiveCursorOffset
      ..targetNode = null
      ..draggedNode = null;
    DragAndDropDetailsListener.of(context).details.value = null;
    _gestures.onDragCanceled?.call(velocity, point);
  }

  void _onDragCompleted() {
    _endDrag();
    _dragListener.dragListener
      ..globalPosition = null
      ..localPosition = null
      ..userPosition = _inactiveCursorOffset
      ..targetNode = null
      ..draggedNode = null;
    _gestures.onDragCompleted?.call(widget.node);
  }

  void _endDrag() {
    isDragging = false;
  }

  // ── Drop target event handlers ──

  NovDragAndDropDetails<Node>? _getDropDetails(
    Offset pointer,
    Node draggedNode, {
    bool starting = false,
  }) {
    if (!mounted) return null;

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

    if (starting && !_dragListener.dragListener.isDragging) {
      _needsInitializeDragListener = false;
      _dragListener.dragListener
        ..draggedNode = draggedNode
        ..targetNode = widget.node
        ..globalPosition = _dragListener.dragListener.userPosition != null
            ? renderBox.localToGlobal(
                _dragListener.dragListener.userPosition!,
              )
            : renderBox.globalToLocal(pointer);
    }

    return NovDragAndDropDetails<Node>(
      draggedNode: _dragListener.dragListener.draggedNode ?? draggedNode,
      globalTargetNodeOffset: offset,
      targetNode: widget.node,
      dropPosition: renderBox
          .globalToLocal(_dragListener.dragListener.globalPosition ?? pointer),
      globalDropPosition: _dragListener.dragListener.globalPosition ?? offset,
      targetBounds: Offset.zero & renderBox.size,
    );
  }

  bool _onWillAccept(DragTargetDetails<Node> details) {
    _details ??= _getDropDetails(
      details.offset,
      details.data,
      starting: _needsInitializeDragListener,
    );
    final bool accepted = _gestures.onWillAcceptWithDetails(
      _details,
      details,
      widget.node,
      widget.owner,
    );
    // ── DEBUG: log drop acceptance decision ──
    if (_details != null) {
      final DragHandlerPosition pos = _details!.exactPosition();
      final bool inside = pos == DragHandlerPosition.into;
      final bool canMoveRaw = Node.canMoveTo(
        node: _details!.draggedNode,
        target: _details!.targetNode,
        inside: inside,
      );
      NodeDebugLogger.log('onWillAccept', <String, Object?>{
        'accepted': accepted,
        'canMoveTo_raw': canMoveRaw,
        'position': pos.name,
        'inside': inside,
        'dragged_id': _details!.draggedNode.id,
        'dragged_hash': identityHashCode(_details!.draggedNode),
        'dragged_owner_id': _details!.draggedNode.owner?.id,
        'target_id': _details!.targetNode.id,
        'target_hash': identityHashCode(_details!.targetNode),
        'target_runtimeType':
            _details!.targetNode.runtimeType.toString(),
        'target_is_NodeContainer':
            _details!.targetNode is NodeContainer,
        'widget_node_hash': identityHashCode(widget.node),
      });
    }
    return accepted;
  }

  void _onMove(DragTargetDetails<Node> details) {
    _cancelHoverExpansion();
    _dragListener.dragListener.targetNode = widget.node;

    setState(() {
      _details = _getDropDetails(details.offset, details.data);
    });

    // ── DEBUG ──
    if (_details != null) {
      NodeDebugLogger.log('onMove', <String, Object?>{
        'position': _details!.exactPosition().name,
        'dragged_id': _details!.draggedNode.id,
        'target_id': _details!.targetNode.id,
      });
    }

    if (details.data.id != widget.node.id) {
      _startHoverExpansion();
    }
    _gestures.onDragMove?.call(details);
  }

  void _onAccept(DragTargetDetails<Node> details) {
    _cancelHoverExpansion();
    _details ??= _getDropDetails(details.offset, details.data);

    if (_details == null || _details!.draggedNode != details.data) return;

    // ── DEBUG ──
    NodeDebugLogger.log('onAccept', <String, Object?>{
      'dragged_id': _details!.draggedNode.id,
      'dragged_hash': identityHashCode(_details!.draggedNode),
      'dragged_owner_id': _details!.draggedNode.owner?.id,
      'target_id': _details!.targetNode.id,
      'position': _details!.exactPosition().name,
    });

    _dragListener.dragListener
      ..draggedNode = null
      ..targetNode = null
      ..globalPosition = null
      ..localPosition = null;

    _gestures.onAcceptWithDetails.call(
      _details!,
      widget.node,
      widget.owner,
    );

    setState(() {
      _details = null;
    });

    // Explicitly clear the inherited listener so any widget
    // depending on DragAndDropDetailsListener stops showing
    // drag feedback (borders, highlights).
    DragAndDropDetailsListener.of(context).details.value = null;
  }

  void _onLeave(Node? data) {
    _needsInitializeDragListener = true;
    _dragListener.dragListener.targetNode = null;

    if (_details == null || data == null || _details!.draggedNode != data) {
      return;
    }

    _cancelHoverExpansion();

    setState(() {
      _details = null;
    });

    _gestures.onLeave?.call(data);
  }

  // ── Hover / auto-expand ──

  void _cancelHoverExpansion() {
    _timer?.cancel();
    _timer = null;
  }

  void _startHoverExpansion() {
    final ComponentContext compCtx = _buildContext();
    widget.builder.onHover(compCtx, _details);

    if (!widget.configuration.draggableConfigurations.allowAutoExpandOnHover &&
        widget.node is NodeContainer) {
      return;
    }

    final bool? isActive = _timer?.isActive;
    if (_timer == null || (isActive != null && !isActive)) {
      _timer = Timer(
        widget.builder.onHoverCallDelay,
        () {
          widget.builder.onTryExpand(compCtx, _details);
        },
      );
    }
  }

  // ── Content builder ──

  /// Builds the visual content for this node.
  ///
  /// Uses [widget.child] when provided (explicit override), otherwise calls
  /// [NodeComponentBuilder.build] with the current [ComponentContext].
  ///
  /// When [candidateData] is non-null (i.e. inside a [DragTarget] builder),
  /// the context's `details` are enriched via [NovDragAndDropDetails.applyData]
  /// to preserve backward-compatible behaviour.
  Widget _buildContent([
    List<dynamic>? rejectedData,
    List<Node?>? candidateData,
  ]) {
    if (widget.child != null) {
      NodeDebugLogger.log('buildContent', <String, Object?>{
        'using_child': true,
        'node_id': widget.node.id,
      });
      return widget.child!;
    }
    final ComponentContext ctx = _buildContext(rejectedData, candidateData);
    NodeDebugLogger.log('buildContent', <String, Object?>{
      'using_child': false,
      'node_id': widget.node.id,
      'details_null': ctx.details == null,
      'details_position': ctx.details?.exactPosition().name,
      'from_dragTarget': candidateData != null,
    });
    return widget.builder.build(ctx);
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool canDrag = widget.node is DragAndDropMixin &&
        widget.node.cast<DragAndDropMixin>().isDraggable() &&
        widget.configuration.activateDragAndDropFeature;

    final bool canDrop = widget.node is DragAndDropMixin &&
        widget.node.cast<DragAndDropMixin>().isDropTarget() &&
        widget.configuration.activateDragAndDropFeature;

    // ── DEBUG: log drag capability decision ──
    NodeDebugLogger.log('build', <String, Object?>{
      'widget_hash': identityHashCode(widget),
      'state_hash': identityHashCode(this),
      'node_hash': identityHashCode(widget.node),
      'node_id': widget.node.id,
      'node_runtimeType': widget.node.runtimeType.toString(),
      'node_is_DragAndDropMixin': widget.node is DragAndDropMixin,
      'canDrag': canDrag,
      'canDrop': canDrop,
      'activateDragAndDropFeature':
          widget.configuration.activateDragAndDropFeature,
      'node_owner_hash': identityHashCode(widget.node.owner),
      'depth': widget.depth,
      'index': widget.index,
      'details_null': _details == null,
      'details_position': _details?.exactPosition().name,
    });

    // Neither drag nor drop — render plain content.
    if (!canDrag && !canDrop) {
      return _buildContent();
    }

    // Build the inner widget stack from inside out.
    Widget inner = _buildContent();

    // Wrap in DragTarget if drop is enabled.
    if (canDrop) {
      inner = _buildDragTarget(childBuilder: _buildContent);
    }

    // Wrap in Draggable if drag is enabled.
    if (canDrag) {
      inner = Listener(
        onPointerMove: (PointerMoveEvent event) =>
            _inactiveCursorOffset = event.localPosition,
        onPointerHover: (PointerHoverEvent event) =>
            _inactiveCursorOffset = event.localPosition,
        onPointerUp: (PointerUpEvent event) => _inactiveCursorOffset = null,
        onPointerCancel: (PointerCancelEvent event) =>
            _inactiveCursorOffset = null,
        child: _buildDraggable(child: inner),
      );
    }

    return inner;
  }

  Widget _buildDraggable({required Widget child}) {
    final cfg = widget.configuration.draggableConfigurations;

    if (cfg.preferLongPressDraggable || cfg.longPressDelay > 0) {
      return LongPressDraggable<Node>(
        data: widget.node,
        maxSimultaneousDrags: 1,
        onDragStarted: _onDragStarted,
        onDragUpdate: _onDragUpdate,
        onDraggableCanceled: _onDraggableCanceled,
        onDragEnd: _gestures.onDragEnd,
        onDragCompleted: _onDragCompleted,
        feedback: cfg.buildDragFeedbackWidget(widget.node, context),
        axis: cfg.axis,
        childWhenDragging: cfg.childWhenDraggingBuilder?.call(widget.node),
        dragAnchorStrategy: (
          Draggable<Object> object,
          BuildContext context,
          Offset position,
        ) {
          return cfg.childDragAnchorStrategy(
            object,
            context,
            _inactiveCursorOffset!,
            position,
          );
        },
        feedbackOffset: cfg.feedbackOffset,
        delay: Duration(milliseconds: cfg.longPressDelay),
        child: child,
      );
    }

    return Draggable<Node>(
      data: widget.node,
      maxSimultaneousDrags: 1,
      onDragStarted: _onDragStarted,
      onDragUpdate: _onDragUpdate,
      onDraggableCanceled: _onDraggableCanceled,
      onDragEnd: _gestures.onDragEnd,
      onDragCompleted: () => _gestures.onDragCompleted?.call(widget.node),
      feedback: cfg.buildDragFeedbackWidget(widget.node, context),
      dragAnchorStrategy: (
        Draggable<Object> object,
        BuildContext context,
        Offset position,
      ) {
        return cfg.childDragAnchorStrategy(
          object,
          context,
          _inactiveCursorOffset!,
          position,
        );
      },
      axis: cfg.axis,
      childWhenDragging: cfg.childWhenDraggingBuilder?.call(widget.node),
      feedbackOffset: cfg.feedbackOffset,
      child: child,
    );
  }

  Widget _buildDragTarget({
    required Widget Function(
      List<dynamic>? rejectedData,
      List<Node?>? candidateData,
    ) childBuilder,
  }) {
    return DragTarget<Node>(
      hitTestBehavior: HitTestBehavior.deferToChild,
      onWillAcceptWithDetails: _onWillAccept,
      onAcceptWithDetails: _onAccept,
      onLeave: _onLeave,
      onMove: _onMove,
      builder: (
        BuildContext context,
        List<Node?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return childBuilder(rejectedData, candidateData);
      },
    );
  }
}
