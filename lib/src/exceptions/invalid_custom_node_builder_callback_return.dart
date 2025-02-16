import '../entities/node/node.dart';

class InvalidCustomNodeBuilderCallbackReturn {
  final String message;
  final Node originalVersionNode;
  final Node newNodeVersion;
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
