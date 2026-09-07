import 'package:flutter/widgets.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

const int _kDefaultExpandDelay = 625;

/// Abstract base class for building and configuring node components in a tree structure.
abstract class NodeComponentBuilder {
  BuildContext? context;
  ComponentContext? componentContext;

  bool isDragging = false;

  bool get mounted => context != null && context!.mounted;

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
  ///   return node is Directory;
  /// }
  /// ```
  bool validate(Node node, int depth);

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
  Widget? buildChildren(ComponentContext context) => null;

  /// Called when we drag a [Node] over this widget
  /// and we maintain that one certain time
  ///
  /// Commonly executed after the delay passed by [onHoverCallDelay]
  void onTryExpand(
      ComponentContext context, NovDragAndDropDetails<Node>? details) {}

  /// Called when we drag a [Node] over this widget
  void onHover(
    ComponentContext context,
    NovDragAndDropDetails<Node>? details,
  ) {}

  /// Determines the delay of the execution of the [onHover] method
  Duration get onHoverCallDelay =>
      const Duration(milliseconds: _kDefaultExpandDelay);

  @mustCallSuper
  void setState(VoidCallback callback) {
    if (!mounted) return;
    callback();
    componentContext?.marksNeedBuild();
  }

  /// Clone the current builder.
  ///
  /// Commonly used during the build of every [Node]
  /// to avoid sharing the same builder instance
  NodeComponentBuilder clone<T extends Node>(T node, BuildContext context);

  /// Called when this object is removed from the tree permanently.
  void dispose(ComponentContext context) {}

  /// Called when a dependency of this [State] object changes.
  ///
  /// For example, if the previous call to [build] referenced an
  /// [InheritedWidget] that later changed, the framework would call this
  /// method to notify this object about the change.
  void didChangeDependencies(ComponentContext context) {}

  /// Called whenever the widget configuration changes.
  ///
  /// If the parent widget rebuilds and requests that this location in the tree
  /// update to display a new widget with the same [runtimeType] and
  /// [Widget.key], the framework will update the [widget] property of this
  /// [State] object to refer to the new widget and then call this method
  /// with the previous widget as an argument.
  void didUpdateWidget(
      ComponentContext context, bool hasEventListeners, Widget oldWidget) {}

  /// Called when this object is inserted into the widgets tree.
  void initState(Node node, int depth) {}

  /// Creates gesture handlers for drag operations on this node.
  NodeDragGestures buildDragGestures(ComponentContext context);

  /// Builds the node's interaction configuration.
  ///
  ///
  /// This method IS NOT designed to react to dynamic states.
  /// Never should be added any type of interaction that depends on the
  /// state of any object, since this is only called when the node properties
  /// changes.
  ///
  /// Example of the limitation:
  ///
  /// 1. Add a tap interaction
  /// 2. Decoration that takes that tap as "this node is selected"
  /// 3. Tap more nodes than the last one.
  /// 4. See how the other nodes are not being rebuilded
  ///
  /// For dynamic states reactions, add directly them to the "build" implementation
  NodeConfiguration? buildConfigurations(ComponentContext context) =>
      NodeConfiguration(touchable: false);

  /// Determines if we will use async build for custom children
  @mustCallSuper
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
