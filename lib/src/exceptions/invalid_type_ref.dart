class InvalidTypeRef implements Exception {
  final String message;
  final Object? data;
  final DateTime time;
  final String targetFail;

  InvalidTypeRef({
    required this.message,
    this.data,
    required this.time,
    required this.targetFail,
  });

  @override
  String toString() {
    return 'InvalidTypeRef => Message: $message | Extra Data $data | Time at: $time | Error From Node: $targetFail';
  }
}
