import 'dart:ui';

import '../entities/node/node.dart';

/// This controller is used by the Drag and Drop
/// feature to know what is the node that is being dragged
/// at the moment
class DragNodeController {
  /// This is the current node that the user is dragging
  /// to another part of the tree
  Node? node;

  /// This represents the current position on the screen
  /// where is the dragged node
  Offset? offset;

  /// This node is the current node where the offset is
  /// if the user put the current dragged node above another
  /// node, then this will be setted
  Node? targetNode;

  DragNodeController._();

  factory DragNodeController() {
    return DragNodeController._()
      ..setOffset = null
      ..setTargetNode = null
      ..setDraggedNode = null;
  }

  factory DragNodeController.values(
      {required Node? node,
      required Offset? offset,
      required Node? targetNode}) {
    return DragNodeController._()
      ..setOffset = offset
      ..setTargetNode = targetNode
      ..setDraggedNode = node;
  }

  factory DragNodeController.byController(
      {required DragNodeController controller}) {
    return DragNodeController._()
      ..setOffset = controller.offset
      ..setTargetNode = controller.targetNode
      ..setDraggedNode = controller.node;
  }

  bool get isDragging => node != null && offset != null;

  set setDraggedNode(Node? node) {
    this.node = node;
  }

  set setOffset(Offset? offset) {
    this.offset = offset;
  }

  set setTargetNode(Node? node) {
    targetNode = node;
  }
}
