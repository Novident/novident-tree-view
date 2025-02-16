import 'package:flutter_tree_view/src/utils/solve_invalid_update.dart';

/// This exception indicates that we cannot updated certain node
///
/// This usually happens when we will update a node using another that does not
/// contains the same identifier (id). Every node only can be updated if the new node
/// has the same identifier (id)
class InvalidNodeUpdate implements Exception {
  final Reason reason;

  const InvalidNodeUpdate({
    required this.reason,
  });

  @override
  String toString() {
    return 'InvalidNodeUpdate => ${reason.reason}';
  }
}
