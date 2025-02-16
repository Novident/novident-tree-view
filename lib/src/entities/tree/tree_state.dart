import '../tree_node/root_node.dart';

/// Represents a simple state
/// of the tree
class TreeState {
  final Root root;

  TreeState({
    required this.root,
  });

  @override
  String toString() {
    return 'TreeState: ${root.details} | Children: ${root.children}';
  }
}
