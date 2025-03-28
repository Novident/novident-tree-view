import 'package:flutter/widgets.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:meta/meta.dart';

abstract class Node extends ChangeNotifier implements MakeDraggable {
  Node();

  String get id;

  /// The level of the node that owns this entry on the tree. Example:
  ///
  /// 0  1  2  3
  /// A  ⋅  ⋅  ⋅
  /// └─ B  ⋅  ⋅
  /// ⋅  ├─ C  ⋅
  /// ⋅  │  └─ D
  /// ⋅  └─ E
  /// F  ⋅
  /// └─ G
  int get level;

  NodeContainer? get owner;

  set owner(NodeContainer? owner);

  @override
  @mustCallSuper
  void dispose() {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    super.dispose();
  }

  @override
  @mustBeOverridden
  bool operator ==(covariant Node other);

  @override
  @mustBeOverridden
  int get hashCode;
}
