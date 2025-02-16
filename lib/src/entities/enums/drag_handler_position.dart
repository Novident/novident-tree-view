/// Represents where is handled this dragging action
///
/// - [BetweenNodes] means that the dragged object, will be inserted above a [Node]
///
/// - [IntoNode] means that the dragged object, will be inserted into a [NodeContainer]
/// as its child
///
/// - [Root] means that the dragged object, will be inserted at [Root] level (zero)
enum DragHandlerPosition {
  betweenNodes,
  intoNode,
  root,
}
