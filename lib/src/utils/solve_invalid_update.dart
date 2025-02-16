import '../entities/node/node.dart';

const String UNPROCESSED_REASON = 'Unprocessed reason';

//TODO: create documentation for this class
class Reason {
  final String reason;
  final Object? extra;
  Reason({required this.reason, this.extra});

  factory Reason.solveInvalidUpdate(Node originalNode, Node newNodeState) {
    Map<String, Node> data = <String, Node>{
      newNodeState.id: newNodeState,
      originalNode.id: originalNode,
    };
    String reason = UNPROCESSED_REASON;
    if (originalNode.runtimeType != newNodeState.runtimeType) {
      reason = 'Both nodes comes from two differents types. '
          'Original: ${originalNode.runtimeType} | NewState: ${newNodeState.runtimeType}';
    }
    if (originalNode.owner != newNodeState.owner) {
      reason =
          'The new state for ${originalNode.runtimeType}(${originalNode.id}) is '
          'invalid since both states has different owner values';
    }
    if (newNodeState.id != originalNode.id) {
      reason =
          'The node ${newNodeState.runtimeType} has not the same identifier from than founded node';
    }
    if (newNodeState.level != originalNode.level) {
      reason =
          'The node ${newNodeState.runtimeType} was founded at [${newNodeState.level}]'
          'instead [${originalNode.level}] from the original node version';
    }

    return Reason(reason: reason, extra: data);
  }
}
