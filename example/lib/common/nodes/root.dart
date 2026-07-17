import 'package:collection/collection.dart';
import 'package:novident_nodes/novident_nodes.dart';

class Root extends NodeContainer {
  Root({
    required super.children,
  }) : super(details: NodeDetails.byId(id: 'root', level: -1)) {
    for (final Node child in children) {
      if (child.owner != this) {
        child.owner = this;
      }
    }
    redepthDescendants();
  }

  @override
  bool operator ==(Object other) {
    if (other is! Root) {
      return false;
    }
    if (identical(this, other)) return true;
    return _equality.equals(children, other.children);
  }

  @override
  int get hashCode => children.hashCode;

  @override
  bool get isEmpty => children.isEmpty;

  @override
  bool get isExpanded => true;

  @override
  set owner(Node? owner) {}

  @override
  Root copyWith({NodeDetails? details, List<Node>? children}) {
    return Root(
      children: children ?? this.children,
    );
  }

  @override
  Root clone({bool deep = true}) {
    return Root(
      children: !deep
          ? children
          : children
              .map(
                (Node e) => e.clone(),
              )
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'root': <String, dynamic>{
        'children': children
            .map<Map<String, dynamic>>(
              (Node e) => e.toJson(),
            )
            .toList(),
      }
    };
  }

  @override
  Root cloneWithNewLevel(int level, {bool deep = true}) {
    return copyWith(
      details: details.cloneWithNewLevel(
        level,
      ),
    );
  }

  @override
  String toString() {
    return 'Root(children: $children)';
  }
}

const ListEquality<Node> _equality = ListEquality<Node>();
