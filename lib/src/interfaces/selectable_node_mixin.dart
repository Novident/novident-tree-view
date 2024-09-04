/// An simple interfaces that gives to the Nodes
/// the ability to be selected
mixin Selectable {
  /// This is called just when
  /// pressed the node
  bool canBePressed();

  /// This is called just when
  /// the user long press the node
  bool canBeSelected({bool isDraggingModeActive = false});
}
