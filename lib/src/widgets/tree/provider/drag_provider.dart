import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controller/drag_node_controller.dart';

final StateProvider<DragNodeController> dragControllerProviderState =
    StateProvider<DragNodeController>(
  (StateProviderRef<DragNodeController> ref) => DragNodeController(),
);

final StateProvider<bool> isDraggingANodeProvider =
    StateProvider((StateProviderRef<bool> ref) => false);
