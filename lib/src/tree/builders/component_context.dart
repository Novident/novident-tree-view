import 'package:flutter/widgets.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// Contextual information container for tree node component construction and configuration.
///
/// Provides essential metadata and utilities for building interactive tree node widgets,
/// handling both visual presentation and user interaction logic.
///
/// ```dart
/// ComponentContext(
///   depth: 2,
///   nodeContext: context,
///   node: myTreeNode,
///   details: dragDetails,
///   wrapWithDragGestures: (ctx, builder, child, useListenable) {
///     //... your implementation
///   },
///   extraArgs: {'theme': darkTheme},
/// );
/// ```
class ComponentContext {
  /// The build context of the node's current position in the widget tree
  final BuildContext nodeContext;

  /// The node's hierarchical depth in the tree structure
  final int depth;

  /// The data node being represented in the tree
  final Node node;

  /// Drag-and-drop operation details (nullable)
  final NovDragAndDropDetails<Node>? details;

  final void Function() marksNeedBuild;

  /// The current index of this component into it's owner
  final int index;

  /// Custom parameters passed through TreeConfiguration
  final Map<String, dynamic> sharedData;

  ComponentContext({
    required this.depth,
    required this.nodeContext,
    required this.node,
    required this.details,
    required this.marksNeedBuild,
    required this.index,
    this.sharedData = const <String, dynamic>{},
  });

  /// Creates a copy of this context replacing the given fields.
  ///
  /// [details] is nullable: omit it to keep the current value, or pass
  /// `null` explicitly to clear it.
  ComponentContext copyWith({
    int? depth,
    BuildContext? nodeContext,
    Node? node,
    NovDragAndDropDetails<Node>? details,
    void Function()? marksNeedBuild,
    int? index,
    Map<String, dynamic>? sharedData,
  }) {
    return ComponentContext(
      depth: depth ?? this.depth,
      nodeContext: nodeContext ?? this.nodeContext,
      node: node ?? this.node,
      details: details ?? this.details,
      marksNeedBuild: marksNeedBuild ?? this.marksNeedBuild,
      index: index ?? this.index,
      sharedData: sharedData ?? this.sharedData,
    );
  }

  @override
  bool operator ==(covariant ComponentContext other) {
    if (identical(this, other)) {
      return true;
    }
    return depth == other.depth &&
        nodeContext == other.nodeContext &&
        node == other.node &&
        details == other.details &&
        marksNeedBuild == other.marksNeedBuild &&
        index == other.index &&
        sharedData == other.sharedData;
  }

  @override
  int get hashCode {
    return depth.hashCode ^
        nodeContext.hashCode ^
        node.hashCode ^
        details.hashCode ^
        marksNeedBuild.hashCode ^
        index.hashCode ^
        sharedData.hashCode;
  }
}
