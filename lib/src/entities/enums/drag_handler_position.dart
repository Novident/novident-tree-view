/// Represents where is handled this dragging action
///
/// - [above] means that the dragged object, will be inserted above a [Node]
///
/// - [into] means that the dragged object, will be inserted into a [Node]
///
/// - [below] means that the dragged object, will be inserted below a [Node]
///
/// - [IntoNode] means that the dragged object, will be inserted into a [NodeContainer]
/// as its child
///
/// - [Root] means that the dragged object, will be inserted at [Root] level (zero)
enum DragHandlerPosition {
  above,
  into,
  below,
  root,
}
