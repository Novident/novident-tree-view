// ignore_for_file: invalid_use_of_protected_member

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
    required this.componentContext,
    this.child,
    super.key,
  });

  final Node node;
  final NodeComponentBuilder builder;
  final TreeConfiguration configuration;
  final int depth;
  final int index;
  final ComponentContext componentContext;

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
  late NodeDragGestures _gestures;

  late final DraggableListener _dragListener = DraggableListener.of(context);

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
        inside: __details!.exactPosition() == DropPosition.inside,
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
    _dragListener.listener.userPosition = __inactiveCursorOffset;
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
      _buildContext(),
    );
  }

  @override
  void dispose() {
    isDragging = false;
    if (mounted) {
      _timer?.cancel();
      _timer = null;
    }
    widget.builder.isDragging = false;
    widget.builder.setState = (VoidCallback fn) {};
    widget.builder.context = null;
    widget.builder.componentContext = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NodeDragAndDropBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.configuration.dragConfig.expandOnHover !=
        widget.configuration.dragConfig.expandOnHover) {
      if (!widget.configuration.dragConfig.expandOnHover) {
        _cancelHoverExpansion();
      }
    }
    widget.builder.isDragging = isDragging;
  }

  ComponentContext _buildContext([
    List<dynamic>? rejectedData,
    List<Node?>? candidateData,
  ]) {
    return widget.componentContext.copyWith(
      details: candidateData == null
          ? _details
          : _details?.applyData(candidateData, rejectedData!),
    );
  }

  void _onDragStarted() {
    isDragging = true;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset cursorPosition = renderBox.localToGlobal(Offset.zero);
    _dragListener.listener
      ..globalPosition = cursorPosition
      ..localPosition = renderBox.globalToLocal(cursorPosition)
      ..targetNode = widget.node
      ..userPosition = _inactiveCursorOffset
      ..draggedNode = widget.node;
    _gestures.onDragStart?.call(cursorPosition, widget.node);
    widget.builder.isDragging = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragListener.listener
      ..globalPosition = details.globalPosition
      ..localPosition = details.localPosition
      ..userPosition = _inactiveCursorOffset
      ..draggedNode = widget.node;
    _gestures.onDragUpdate?.call(details);
  }

  void _onDraggableCanceled(Velocity velocity, Offset point) {
    _endDrag();
    _dragListener.listener
      ..globalPosition = null
      ..localPosition = null
      ..userPosition = _inactiveCursorOffset
      ..targetNode = null
      ..draggedNode = null;
    DragAndDropDetailsListener.of(context).details.value = null;
    _gestures.onDragCanceled?.call(velocity, point);
    widget.builder.isDragging = false;
  }

  void _onDragCompleted() {
    _endDrag();
    _dragListener.listener
      ..globalPosition = null
      ..localPosition = null
      ..userPosition = _inactiveCursorOffset
      ..targetNode = null
      ..draggedNode = null;
    _gestures.onDragCompleted?.call(widget.node);
  }

  void _endDrag() {
    isDragging = false;
    widget.builder.isDragging = false;
  }

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
        'not attached inside the widgets tree',
      );
    }

    final Vector3 vectorPosition =
        renderBox.getTransformTo(null).getTranslation();
    final Offset offset = Offset(vectorPosition.x, vectorPosition.y);

    if (starting && !_dragListener.listener.isDragging) {
      _needsInitializeDragListener = false;
      _dragListener.listener
        ..draggedNode = draggedNode
        ..targetNode = widget.node
        ..globalPosition = _dragListener.listener.userPosition != null
            ? renderBox.localToGlobal(
                _dragListener.listener.userPosition!,
              )
            : renderBox.globalToLocal(pointer);
    }

    return NovDragAndDropDetails<Node>(
      draggedNode: _dragListener.listener.draggedNode ?? draggedNode,
      globalTargetNodeOffset: offset,
      targetNode: widget.node,
      dropPosition: renderBox
          .globalToLocal(_dragListener.listener.globalPosition ?? pointer),
      globalDropPosition: _dragListener.listener.globalPosition ?? offset,
      targetBounds: Offset.zero & renderBox.size,
      topZoneHeight: widget.configuration.topZoneHeight,
      bottomZoneHeight: widget.configuration.bottomZoneHeight,
    );
  }

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

  void _onMove(DragTargetDetails<Node> details) {
    _cancelHoverExpansion();
    _dragListener.listener.targetNode = widget.node;

    setState(() {
      _details = _getDropDetails(details.offset, details.data);
    });

    if (details.data.id != widget.node.id) {
      _startHoverExpansion();
    }
    _gestures.onDragMove?.call(details);
  }

  void _onAccept(DragTargetDetails<Node> details) {
    _cancelHoverExpansion();
    _details ??= _getDropDetails(details.offset, details.data);

    if (_details == null || _details!.draggedNode != details.data) return;

    // Do NOT clear _dragListener.listener here — that belongs to
    // the Draggable lifecycle (_onDragCompleted / _onDraggableCanceled).
    // Clearing it here would zero globalPosition while the drag feedback
    // widget is still visible, because both live in the same unified state
    // (unlike the old separate Widget architecture).
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
    widget.builder.isDragging = false;
  }

  void _onLeave(Node? data) {
    _needsInitializeDragListener = true;
    _dragListener.listener.targetNode = null;

    if (_details == null || data == null || _details!.draggedNode != data) {
      return;
    }

    _cancelHoverExpansion();

    setState(() {
      _details = null;
    });

    _gestures.onLeave?.call(data);
    widget.builder.isDragging = false;
  }

  void _cancelHoverExpansion() {
    _timer?.cancel();
    _timer = null;
  }

  void _startHoverExpansion() {
    final ComponentContext compCtx = _buildContext();
    widget.builder.onHover(compCtx, _details);

    if (!widget.configuration.dragConfig.expandOnHover &&
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
      return widget.child!;
    }
    final ComponentContext ctx = _buildContext(
      rejectedData,
      candidateData,
    );
    widget.builder.isDragging = isDragging;
    return widget.builder.build(ctx);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool canDrag = widget.node is DragAndDropMixin &&
        widget.node.cast<DragAndDropMixin>().isDraggable() &&
        widget.configuration.activateDragAndDropFeature;

    final bool canDrop = widget.node is DragAndDropMixin &&
        widget.node.cast<DragAndDropMixin>().isDropTarget() &&
        widget.configuration.activateDragAndDropFeature;

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
    final cfg = widget.configuration.dragConfig;

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
      onDragCompleted: _onDragCompleted,
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
