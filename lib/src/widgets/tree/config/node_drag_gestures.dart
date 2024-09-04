import 'package:flutter/material.dart';
import '../../../entities/enums/drag_handler_position.dart';
import '../../../entities/tree_node/tree_node.dart';

import '../../../entities/drag/dragged_object.dart';
import '../../../entities/tree_node/composite_tree_node.dart';
import '../../../entities/tree_node/leaf_tree_node.dart';

typedef CustomWillAcceptOnCompositeNode = bool Function(
  DragTargetDetails<TreeNode> details,
  CompositeTreeNode currentNode,
  CompositeTreeNode? parent,
  DragHandlerPosition handlerPosition,
);

typedef CustomAcceptOnCompositeNode = void Function(
  DragTargetDetails<TreeNode> details,
  CompositeTreeNode currentNode,
  CompositeTreeNode? parent,
  DragHandlerPosition handlerPosition,
);

typedef CustomWillAcceptOnLeafNode = bool Function(
  DragTargetDetails<TreeNode> details,
  LeafTreeNode currentNode,
  CompositeTreeNode? parent,
  DragHandlerPosition handlerPosition,
);

typedef CustomAcceptOnLeafNode = void Function(
  DragTargetDetails<TreeNode> details,
  LeafTreeNode currentNode,
  CompositeTreeNode? parent,
  DragHandlerPosition handlerPosition,
);

typedef CustomWillAcceptOnRootNode = bool Function(
  DragTargetDetails<TreeNode> details,
);

typedef CustomAcceptOnRootNode = void Function(
  DragTargetDetails<TreeNode> details,
);

/// Represents all operations of the most common
/// used drag operatons/gestures by the users
@immutable
class NodeDragGestures {
  final void Function(DraggedObject, TreeNode node)? onDragStart;

  /// By default this just update [DragNodeController] updating
  /// the current dragged object, and the offset where it is
  /// using [details.globalPosition]
  final void Function(DragUpdateDetails details, TreeNode node)? onDragMove;

  /// If the drag ends, then this will be called
  ///
  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(DraggableDetails)? onDragEnd;

  /// If the drag is cancelled while is into a valid draggable node,
  /// then this will be called
  ///
  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(DraggableDetails)? onDragCanceled;

  /// by default this functions just reset the state
  /// of the [DragNodeController]
  final void Function(Velocity velocity, Offset offset)? onDragCompleted;
  // These gestures will be used on both sides
  // on insert above and into the node.
  // the unique way to know is the operation will be handled
  // on between nodes section is if [handlerPosition] is handlerPosition.betweenNodes
  ///
  /// ### Composite drag target functions
  /// Does not override the default implementation
  /// since it only makes the changes required by the tree operation
  final CustomWillAcceptOnCompositeNode? customCompositeOnWillAcceptWithDetails;

  /// ### Composite drag target functions
  /// Does not override the default implementation
  /// since it only makes the changes required by the tree operation
  final CustomAcceptOnCompositeNode? customCompositeOnAcceptWithDetails;
  // These gestures will be used on both sides
  // on insert above and into the node.
  // the unique way to know is the operation will be handled
  // on between nodes section is if [handlerPosition] is handlerPosition.betweenNodes
  ///
  /// ### Leaf drag target functions
  /// Does not override the default implementation
  /// since it only makes the changes required by the tree operation
  final CustomWillAcceptOnLeafNode? customLeafOnWillAcceptWithDetails;

  /// ### Leaf drag target functions
  /// Does not override the default implementation
  /// since it only makes the changes required by the tree operation
  final CustomAcceptOnLeafNode? customLeafOnAcceptWithDetails;

  /// ### Root drag target functions
  /// Does not override the default implementation
  /// since it only makes the changes required by the tree operation
  final CustomWillAcceptOnRootNode? customRootOnWillAcceptWithDetails;

  /// ### Root drag target functions
  /// Does not override the default implementation
  /// since it only makes the changes required by the tree operation
  final CustomAcceptOnRootNode? customRootOnAcceptWithDetails;

  const NodeDragGestures({
    this.onDragStart,
    this.onDragMove,
    this.onDragEnd,
    this.onDragCanceled,
    this.onDragCompleted,
    this.customCompositeOnWillAcceptWithDetails,
    this.customCompositeOnAcceptWithDetails,
    this.customLeafOnWillAcceptWithDetails,
    this.customLeafOnAcceptWithDetails,
    this.customRootOnAcceptWithDetails,
    this.customRootOnWillAcceptWithDetails,
  });
}
