import 'package:flutter/widgets.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// Abstract base class for building and configuring node components in a tree structure.
abstract class NodeComponentBuilder {
  /// Determines whether this builder should handle the given node.
  ///
  /// The tree will call this method to check if this builder is appropriate
  /// for rendering the specified node.
  ///
  /// Returns `true` if this builder should be used, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool validate(Node node) {
  ///   return node is Directory ||
  ///     node is DirectoryTrashed;
  /// }
  /// ```
  bool validate(Node node);

  /// Creates gesture handlers for drag operations on this node.
  NodeDragGestures buildDragGestures(ComponentContext context);

  /// Builds the node's interaction configuration.
  NodeConfiguration? buildConfigurations(ComponentContext context) =>
      NodeConfiguration(makeTappable: false);

  /// Constructs the visual representation of the node.
  ///
  /// This is the primary method that defines how the node appears in the tree.
  /// The returned widget will be wrapped with any gestures and configurations
  /// created by other builder methods.
  Widget build(ComponentContext context);

  /// Optionally builds a custom layout for this node's children.
  ///
  /// When null (the default), children are rendered using the tree's standard
  /// layout algorithm. When provided, this completely overrides child rendering.
  Widget? buildChildren(ComponentContext context);
}
