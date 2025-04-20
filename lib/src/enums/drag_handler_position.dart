/// Represents where is handled this dragging action
///
/// - [above] means that the dragged object, will be inserted above a [Node]
///
/// - [into] means that the dragged object, will be inserted into a [Node]
///
/// - [below] means that the dragged object, will be inserted below a [Node]
enum DragHandlerPosition {
  above,
  into,
  below,
  unknown,
}
