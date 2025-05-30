import 'package:example/common/nodes/root.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'base/base_tree_controller.dart';

/// The [`TreeController`] manages a tree of nodes, allowing for querying Nodes.
class TreeController extends BaseTreeController {
  TreeController({required Root root}) : _root = root;

  final Root _root;

  @override
  Root get root => _root;

  /// Removes the current node selected
  void invalidateSelection() {
    selectNode(null);
  }

  void selectFirstNode() {
    if (isEmpty) return;
    selectNode(root.first);
  }

  void selectLastNode() {
    if (isEmpty) return;
    selectNode(root.last);
  }

  bool expandAllUntilTarget(Node targetNode,
      {bool openTargetIfNeeded = false}) {
    assert(targetNode.level >= 0);

    Future<bool> expandNodeWhen(List<Node> tree,
        {bool ignoreBySubNode = false}) async {
      for (int i = 0; i < tree.length; i++) {
        Node node = tree.elementAt(i);
        // the target was founded
        if (node is NodeContainer &&
            node.id == targetNode.id &&
            openTargetIfNeeded &&
            node.details.level == 0) {}
        if (node is NodeContainer &&
            node.id == targetNode.id &&
            openTargetIfNeeded) {
          node.asDirectory.openOrClose(forceOpen: true);
        }
        if (node.id == targetNode.id) {
          return true;
        }
        if (node is NodeContainer && node.isNotEmpty) {
          bool founded =
              await expandNodeWhen(node.children, ignoreBySubNode: true);
          if (founded) {
            return true;
          }
        }
      }
      return false;
    }

    expandNodeWhen(root.children);
    return true;
  }

  void clearTree() {
    root.clear();
  }
}
