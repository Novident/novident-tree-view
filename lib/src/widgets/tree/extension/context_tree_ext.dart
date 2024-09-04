import 'package:flutter/widgets.dart';
import '../../../controller/drag_node_controller.dart';
import '../../../controller/tree_controller.dart';
import '../provider/drag_provider.dart';
import '../provider/tree_notifier_provider.dart';

extension BuildContextTreeExt on BuildContext {
  void disposeTree() => readTree().dispose();
  TreeController readTree() => TreeNotifierProvider.of(this, listen: false);
  DragNodeController readDrag() => DragNotifierProvider.of(this, listen: false);
  DragNodeController watchDrag() => DragNotifierProvider.of(this, listen: true);
  TreeController watchTree() => TreeNotifierProvider.of(this, listen: true);
}
