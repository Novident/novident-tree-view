import 'dart:async';

import 'package:flutter_tree_view/src/entities/node/node_details.dart';
import 'package:flutter_tree_view/src/entities/tree_node/node_container.dart';
import 'package:meta/meta.dart';

import '../node/node.dart';
import '../tree/tree_changes.dart';
import '../tree/tree_operation.dart';
import '../tree/tree_state.dart';

/// Represents the root of the directory view
class Root extends NodeContainer<Node> {
  @protected
  final StreamController<TreeStateChanges> _rootState =
      StreamController.broadcast();

  Root({
    required super.details,
    required super.children,
    super.isExpanded = true,
  });

  /// By now we just use a [simple list] in future release we **could replace** this
  /// by a more complex stack with the states of the tree before and after, like **undo** and **redo**
  /// **features** from any [text editor]
  Stream<TreeStateChanges> get changes => _rootState.stream;

  @internal
  void addNewChange(List<Node> nodes, TreeOperation op, [Node? changedNode]) {
    final oldState = TreeState(root: this);
    final change =
        TreeChange(children: nodes, operation: op, node: changedNode);
    final TreeStateChanges changes = TreeStateChanges(
      oldState: oldState,
      change: change,
    );
    _rootState.add(changes);
  }

  @internal
  @override
  bool canDrag({bool isSelectingModeActive = false}) => false;

  @internal
  @override
  bool canDrop({Node? target}) => true;

  @internal
  @override
  Root clone() {
    return Root(
      details: details,
      children: children,
      isExpanded: isExpanded,
    );
  }

  @override
  Root copyWith({
    NodeDetails? details,
    List<Node>? children,
    bool? isExpanded,
  }) {
    return Root(
      details: details ?? this.details,
      children: children ?? this.children,
      isExpanded: false,
    );
  }

  @internal
  @override
  void dispose() {
    super.dispose();
    _rootState.close();
    clear();
  }

  @override
  List<Object?> get props => [details, children, isExpanded];
}
