class InvalidNodeId implements Exception {
  final String message;

  const InvalidNodeId({required this.message});

  @override
  String toString() {
    return 'InvalidNodeId => $message';
  }
}
