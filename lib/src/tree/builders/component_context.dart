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

  /// Gesture wrapper factory for adding drag interactions
  ///
  /// - [context]: Current component context
  /// - [builder]: Node component builder reference
  /// - [child]: Underlying widget to wrap
  /// - [wrapWithListenableBuilder]: Flag for reactive rebuilds
  final Widget Function(
    ComponentContext context,
    NodeComponentBuilder builder,
    Widget child,
    bool wrapWithListenableBuilder,
  ) wrapWithDragGestures;

  /// Custom parameters passed through TreeConfiguration
  final Map<String, dynamic> extraArgs;

  ComponentContext({
    required this.depth,
    required this.nodeContext,
    required this.node,
    required this.details,
    required this.wrapWithDragGestures,
    required this.marksNeedBuild,
    this.extraArgs = const <String, dynamic>{},
  });
}
