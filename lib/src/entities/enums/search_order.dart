/// Represents a way to decide the strategy
/// of a search
///
/// [First] if found the TreeNode and this is a [CompositeTreeNode]
/// will return the first elemento this the founded [CompositeTreeNode]
///
/// [Back] if founded the TreeNode will get the element before the founded one
///
/// [Target] if founded the TreeNode return it
///
/// [Next] if founded the TreeNode will get the element next the founded one
///
/// [Last] if found the TreeNode and this is a [CompositeTreeNode]
/// will return the last elemento this the founded [CompositeTreeNode]
enum SearchStrategy {
  first,
  back,
  target,
  next,
  last,
}
