import 'package:flutter/foundation.dart';
import '../tree_node/selectable_tree_node.dart';

class NodeSelection {
  NodeSelection({
    required this.selection,
  });

  final List<SelectableTreeNode> selection;

  SelectableTreeNode elementAt(int index) {
    return selection.elementAt(index);
  }

  SelectableTreeNode? elementAtOrNull(int index) {
    return selection.elementAtOrNull(index);
  }

  bool contains(SelectableTreeNode object) {
    return selection.contains(object);
  }

  bool checkExistence(String nodeId) {
    for (var node in selection) {
      if (node.node.id == nodeId) return true;
    }
    return false;
  }

  SelectableTreeNode get first => selection.first;
  SelectableTreeNode get last => selection.last;
  SelectableTreeNode? get lastOrNull => selection.lastOrNull;
  SelectableTreeNode? get firstOrNull => selection.firstOrNull;
  Iterator<SelectableTreeNode> get iterator => selection.iterator;
  Iterable<SelectableTreeNode> get reversed => selection.reversed;
  bool get isEmpty => selection.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => selection.length;

  int indexWhere(bool Function(SelectableTreeNode) callback) {
    return selection.indexWhere(callback);
  }

  int indexOf(SelectableTreeNode element, int start) {
    return selection.indexOf(element, start);
  }

  SelectableTreeNode firstWhere(bool Function(SelectableTreeNode) callback) {
    return selection.firstWhere(callback);
  }

  SelectableTreeNode lastWhere(bool Function(SelectableTreeNode) callback) {
    return selection.lastWhere(callback);
  }

  void add(SelectableTreeNode element) {
    selection.add(element);
  }

  void addAll(Iterable<SelectableTreeNode> selection) {
    this.selection.addAll(selection);
  }

  void insert(int index, SelectableTreeNode element) {
    selection.insert(index, element);
  }

  void clear() {
    selection.clear();
  }

  bool remove(SelectableTreeNode element) {
    return selection.remove(element);
  }

  SelectableTreeNode removeLast() {
    return selection.removeLast();
  }

  void removeWhere(bool Function(SelectableTreeNode) callback) {
    selection.removeWhere(callback);
  }

  SelectableTreeNode removeAt(int index) {
    return selection.removeAt(index);
  }

  void operator []=(int index, SelectableTreeNode format) {
    if (index < 0) return;
    selection[index] = format;
  }

  SelectableTreeNode operator [](int index) {
    return selection[index];
  }

  @override
  bool operator ==(covariant NodeSelection other) {
    if (identical(this, other)) return true;
    return listEquals(selection, other.selection);
  }

  @override
  int get hashCode => Object.hashAll([selection]);
}
