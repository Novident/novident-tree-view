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
    redepthChildren(checkFirst: true);
  }

  /// adjust the depth level of the children
  void redepthChildren({int? currentLevel, bool checkFirst = false}) {
    void redepth(List<Node> unformattedChildren, int currentLevel) {
      for (int i = 0; i < unformattedChildren.length; i++) {
        final Node node = unformattedChildren.elementAt(i);
        unformattedChildren[i] = node.cloneWithNewLevel(currentLevel + 1);
        if (node is NodeContainer && node.isNotEmpty) {
          redepth(node.children, currentLevel + 1);
        }
      }
    }

    bool ignoreRedepth = false;
    if (checkFirst) {
      final int childLevel = level + 1;
      for (final child in children) {
        if (child.level != childLevel) {
          ignoreRedepth = true;
          break;
        }
      }
    }
    if (ignoreRedepth) return;

    redepth(children, currentLevel ?? level);
    notify();
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
  Root clone() {
    return Root(
      children: children
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
  Root cloneWithNewLevel(int level) {
    return copyWith(
      details: details.cloneWithNewLevel(
        level,
      ),
    );
  }
}

const ListEquality<Node> _equality = ListEquality<Node>();
