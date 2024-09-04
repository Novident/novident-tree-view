import '../entities/tree_node/tree_node.dart';

class InvalidCustomNodeBuilderCallbackReturn {
  final String message;
  final TreeNode originalVersionNode;
  final TreeNode newNodeVersion;
  final String? reason;

  const InvalidCustomNodeBuilderCallbackReturn({
    required this.message,
    required this.originalVersionNode,
    required this.newNodeVersion,
    this.reason,
  });

  @override
  String toString() {
    return 'InvalidCustomNodeBuilderCallbackReturn => $message | $originalVersionNode | $newNodeVersion | $reason';
  }
}
