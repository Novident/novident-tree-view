class NodeNotExistInTree implements Exception {
  final String message;
  final String node;

  NodeNotExistInTree({
    required this.message,
    required this.node,
  });

  @override
  String toString() {
    return 'NodeNotExistInTree => $message | $node';
  }
}
