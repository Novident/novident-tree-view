/// Compute the correct indent based on the level
/// of the common [CompositeTreeNode] implementation
double computePaddingForComposite(int level) {
  return (((level * 3) + 2) * 7); // directorios
}

/// Compute the correct indent based on the level
/// of the [CompositeTreeNodes] that have no the expandable button
/// as the leadinh
double computePaddingForCompositeWithoutExpandable(int level) {
  return (((level * 3) + 1) * 7) + (level + 10); // directorios
}

/// Compute the correct indent based on the level
/// for the common [LeafTreeNode] implementation
double computePaddingForLeaf(int level) {
  return (((level * 3) + 2) * 7) + 38.5;
}

/// Compute the correct indent based on the level
/// for the common [LeafTreeNode] implementation when the
/// expandable button is hidden in the [CompositeTreeNode]
double computePaddingForLeafWithoutExpandable(int level) {
  return (((level * 3) + 2) * 7) + (level + 8);
}
