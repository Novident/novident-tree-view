/// This exceptions indicates that the operation what is running
/// cannot be executed completely because something fails
class InvalidOperation implements Exception {
  final String message;
  final String? typeOp;

  const InvalidOperation({
    required this.message,
    this.typeOp,
  });

  @override
  String toString() {
    return 'InvalidOperation => $message | $typeOp';
  }
}
