import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import '../../../controller/drag_node_controller.dart';

// We use these internal states to determine if the user
// is dragging an item or not.
//
// Usually, we use DragNodeController in the nodes section
// to draw correctly some extra widgets
//
@internal
final StateProvider<DragNodeController> dragControllerProviderState =
    StateProvider<DragNodeController>(
  (Ref<DragNodeController> ref) => DragNodeController(),
);

@internal
final StateProvider<bool> isDraggingANodeProvider =
    StateProvider((Ref<bool> ref) => false);
