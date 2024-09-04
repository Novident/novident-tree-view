import '../entities/tree_node/tree_node.dart';

class InvalidNodeUpdate {
  final String message;
  final TreeNode originalVersionNode;
  final TreeNode newNodeVersion;
  final String? reason;

  const InvalidNodeUpdate({
    required this.message,
    required this.originalVersionNode,
    required this.newNodeVersion,
    this.reason,
  });

  @override
  String toString() {
    return 'InvalidNodeUpdate => $message | $originalVersionNode | $newNodeVersion | $reason';
  }
}
