import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../entities/drag/dragged_object.dart';
import '../entities/tree_node/tree_node.dart';

/// This controller is used by the Drag and Drop
/// feature to know what is the node that is being dragged
/// at the moment
class DragNodeController extends ChangeNotifier {
  final DraggedObject _draggedObject = DraggedObject();
  DraggedObject get object => _draggedObject;
  TreeNode? get node => _draggedObject.node;
  TreeNode? get targetNode => _draggedObject.targetNode;
  Offset? get offset => _draggedObject.offset;

  bool get isDragging => node != null;

  set setDraggedNode(TreeNode? node) {
    _draggedObject.node = node;
    notifyListeners();
  }

  set setOffset(Offset? offset) {
    _draggedObject.offset = offset;
    notifyListeners();
  }

  set setTargetNode(TreeNode? node) {
    _draggedObject.targetNode = node;
    notifyListeners();
  }

  @override
  bool operator ==(covariant DragNodeController other) {
    if (identical(this, other)) return true;
    return _draggedObject == other._draggedObject;
  }

  @override
  int get hashCode => Object.hashAll(
        [
          _draggedObject,
        ],
      );
}
