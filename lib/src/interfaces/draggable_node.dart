/// An simple interfaces that gives to the Nodes
/// the ability to be dragged and dropped in some
/// node parents
mixin MakeDraggable {
  /// Decides if the user can drag the
  /// item to drop on another side
  bool canDrag();
  bool canSiblingsDropInto();
}
