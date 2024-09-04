/// Represents where is handle this drag actions
/// # Position Options and what means them
///
/// [BetweenNodes] means the sections where will be applied the actions
/// only when a node will be moved above another one
///
/// [IntoNode] means the section where will be applied the actions
/// only when the dragged node will be inserted into a [CompositeTreeNode]
///
/// [Root] means the section where all nodes that are not into the root
/// tree level. If the node already exist into the root, will be ignored
enum DragHandlerPosition {
  betweenNodes,
  intoNode,
  root,
}
