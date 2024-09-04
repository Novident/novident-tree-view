import 'package:flutter/material.dart';
import '../../../controller/tree_controller.dart';

/// The `TreeNotifierProvider` is a specialized `InheritedWidget` that serves as a provider for a 
/// `TreeController` in a widget tree. It ensures that the `TreeController` is accessible to all 
/// descendant widgets, allowing them to interact with and respond to changes in the tree structure 
/// managed by the controller.
@immutable
class TreeNotifierProvider extends InheritedWidget {
  final TreeController controller;

  const TreeNotifierProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Get the TreeNotifierProvider by the given context
  ///
  /// Ensure of before call this method, the provider is already registered
  /// in the widgets tree
  ///
  /// Set [listen] to true if you want to get an instance that updates when
  /// the TreeController changes
  static TreeController of(BuildContext context, {bool listen = true}) {
    if (!context.mounted) {
      throw Exception(
          'You cannot use TreeNotifierProvider.of(...) if the context is no longer stable or mounted into the widgets tree');
    }
    if (listen) {
      return (context
              .dependOnInheritedWidgetOfExactType<TreeNotifierProvider>())!
          .controller;
    }
    return (context.getInheritedWidgetOfExactType<TreeNotifierProvider>())!
        .controller;
  }

  @override
  bool updateShouldNotify(covariant TreeNotifierProvider oldWidget) {
    // we do not use controller != oldWidget.controller because
    // the tree can be too deeper and the equals cannot really know
    // exactly if a part of the tree changes because we would need
    // traverse into it manually a decide if some child is different from
    // the other ones
    return true;
  }
}
