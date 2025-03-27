import 'package:flutter/foundation.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class Root extends NodeContainer<Node> {
  Root({
    required super.children,
  });

  @override
  bool operator ==(covariant Root other) {
    if(identical(this, other)) return true;
    return listEquals(children, other.children);
  }

  @override
  int get hashCode => children.hashCode;

  @override
  String get id => 'root';

  @override
  bool get isEmpty => children.isEmpty;

  @override
  bool get isExpanded => true;

  @override
  int get level => -1;

  @override
  NodeContainer<Node>? get owner => null;

  @override
  bool canDrag() {
    return false;
  }

  @override
  bool canDrop({required Node target}) {
    return true;
  }
}
