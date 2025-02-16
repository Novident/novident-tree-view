import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree_view/src/entities/node/node_details.dart';
import 'package:flutter_tree_view/src/entities/node/node_notifier.dart';

abstract class Node extends NodeNotifier with EquatableMixin {
  final NodeDetails details;
  final LayerLink layer = LayerLink();
  Node({
    required this.details,
  });

  void notify() {
    notifyListeners();
  }

  String get id => details.id;
  int get level => details.level;
  String? get owner => details.owner;

  Node clone();
  Node copyWith({NodeDetails? details});

  @override
  String toString() {
    return 'Node(details: $details)';
  }
}
