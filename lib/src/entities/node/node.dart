import 'package:flutter/widgets.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:meta/meta.dart';

abstract class Node extends ChangeNotifier implements MakeDraggable {
  Node();

  String get id;
  int get level;
  NodeContainer? get owner;

  @override
  @mustBeOverridden
  bool operator ==(covariant Node other);
  @override
  @mustBeOverridden
  int get hashCode;
}
