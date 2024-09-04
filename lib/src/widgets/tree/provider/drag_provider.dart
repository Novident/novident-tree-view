import 'package:flutter/material.dart';
import '../../../controller/drag_node_controller.dart';

@immutable
class DragNotifierProvider extends InheritedWidget {
  final DragNodeController controller;

  const DragNotifierProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Get the DragNotifierProvider by the given context
  ///
  /// Ensure of before call this method, the provider is already registered
  /// in the widgets tree
  ///
  /// Set [listen] to true if you want to get an instance that updates when
  /// the TreeController changes
  static DragNodeController of(BuildContext context, {bool listen = true}) {
    if (!context.mounted)
      throw Exception(
          'You cannot use DragNotifierProvider.of(...) if a context that is no longer into the widgets tree');
    if (listen)
      return (context.dependOnInheritedWidgetOfExactType<DragNotifierProvider>()
              as DragNotifierProvider)
          .controller;
    return (context.getInheritedWidgetOfExactType<DragNotifierProvider>()
            as DragNotifierProvider)
        .controller;
  }

  @override
  bool updateShouldNotify(covariant DragNotifierProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
