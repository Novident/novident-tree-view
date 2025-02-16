import 'package:flutter/widgets.dart';
import '../../../controller/tree_controller.dart';
import '../provider/tree_notifier_provider.dart';

extension BuildContextTreeExt on BuildContext {
  void disposeTree() => readTree().dispose();
  TreeController readTree() => TreeNotifierProvider.of(this, listen: false);
  TreeController watchTree({bool listen = true}) =>
      TreeNotifierProvider.of(this, listen: listen);
}
