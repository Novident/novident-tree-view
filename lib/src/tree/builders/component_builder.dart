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
  bool validate(Node node, int depth);

  /// Determines whether this builder wont be cached the tree widgets
  bool get avoidCacheBuilder => false;

  /// Called when this object is removed from the tree permanently.
  void dispose(ComponentContext context) {}

  /// Called when a dependency of this [State] object changes.
  ///
  /// For example, if the previous call to [build] referenced an
  /// [InheritedWidget] that later changed, the framework would call this
  /// method to notify this object about the change.
  void didChangeDependencies(
      ComponentContext context, bool hasNotifierAttached) {}

  /// Called whenever the widget configuration changes.
  ///
  /// If the parent widget rebuilds and requests that this location in the tree
  /// update to display a new widget with the same [runtimeType] and
  /// [Widget.key], the framework will update the [widget] property of this
  /// [State] object to refer to the new widget and then call this method
  /// with the previous widget as an argument.
  void didUpdateWidget(ComponentContext context, bool hasNotifierAttached) {}

  /// Called when this object is inserted into the widgets tree.
  void initState(Node node, int depth) {}

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

  /// Determines if we will use async build for custom children
  bool get useAsyncBuild => false;

  /// Determines if we will use the async calls
  /// in every reload of the node container widget
  ///
  /// * If true is provided, will use [buildChildrenAsync] once time
  /// and after will use non async functions (tree's standard rendering
  /// or the [buildChildren] if it's provided)
  ///
  /// * If false is provided, will use [buildChildrenAsync] every time
  /// the container widget is reloaded
  bool get cacheChildrenAfterFirstAsyncBuild => false;

  /// Optionally builds a custom children layout using Futures
  ///
  /// When null or [useAsyncBuild] returns false, children are
  /// rendered using the tree's standard layout algorithm.
  Future<List<Widget>?> buildChildrenAsync(ComponentContext context) async =>
      null;

  /// Constructs a visual placeholder that will be showed while
  /// the data is being loaded into [buildChildrenAsync]
  Widget? buildChildrenAsyncPlaceholder(ComponentContext context) => null;

  /// Constructs a visual widget error that will be showed if the
  /// [FutureBuilder] gets an error instead data
  Widget? buildChildrenAsyncError(
    ComponentContext context,
    StackTrace? stacktrace,
    Object error,
  ) =>
      null;
}
