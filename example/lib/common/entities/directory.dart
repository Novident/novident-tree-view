import 'package:flutter_tree_view/flutter_tree_view.dart';

class Directory extends NodeContainer<Node> {
  final String name;
  final DateTime createAt;

  Directory({
    required super.children,
    required super.details,
    super.isExpanded,
    required this.name,
    required this.createAt,
  });

  @override
  Directory copyWith({
    NodeDetails? details,
    List<Node>? children,
    bool? isExpanded,
    String? name,
    DateTime? createAt,
  }) {
    return Directory(
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      details: details ?? this.details,
      name: name ?? this.name,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  List<Object?> get props => [details, children, isEmpty, name, createAt];

  @override
  String toString() {
    return 'Directory(name: $name, isExpanded: $isExpanded, children: ${children.length})';
  }

  @override
  Directory clone() {
    return Directory(
      children: children,
      details: NodeDetails.withLevel(level),
      name: name,
      createAt: createAt,
    );
  }
}
