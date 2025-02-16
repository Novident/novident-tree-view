import 'package:flutter_tree_view/src/entities/node/node.dart';
import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';
import '../../interfaces/draggable_node.dart';

/// LeafNode represents a simple type of node
///
/// You can see this implementation as a file from a directory
/// that can contain all type data into itself
abstract class LeafNode extends Node implements MakeDraggable {
  LeafNode({
    required super.details,
  });

  @override
  LeafNode clone();

  @override
  bool canDrag() {
    return true;
  }

  @override
  bool canDrop({required Node target}) {
    return target is NodeContainer;
  }

  @override
  String toString() {
    return 'LeafNode(details: $details)';
  }
}
