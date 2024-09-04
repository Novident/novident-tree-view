// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import '../tree_node/tree_node.dart';

class DraggedObject extends Equatable {
  /// This is the current node that the user is dragging
  /// to another part of the tree
  TreeNode? node;

  /// This represents the current position on the screen
  /// where is the dragged node
  Offset? offset;

  /// This node is the current node where the offset is
  /// if the user put the current dragged node above another
  /// node, then this will be setted
  TreeNode? targetNode;

  @override
  List<Object?> get props => [node, offset, targetNode];
}
