import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';
import 'package:provider/provider.dart';

/// Widget that applies indentation to tree nodes based on their depth level
///
/// This widget calculates the appropriate left padding based on:
/// - The node's depth level
/// - The indentation configuration
/// - Any additional padding specified
class AutomaticNodeIndentation extends StatelessWidget {
  /// The widget to be indented (typically the node's content)
  final Widget child;

  /// The tree node containing level information
  final Node node;

  /// Creates an indentation widget for tree nodes
  ///
  /// [node]: The tree node to determine indentation level
  /// [configuration]: Indentation settings to apply
  /// [child]: The content widget to be indented
  const AutomaticNodeIndentation({
    required this.node,
    required this.child,
    super.key,
  });

  /// Constrains the indentation level to the configured maximum
  ///
  /// Returns the minimum between the node's level and the configured maxLevel
  int _constrainLevel(int level, IndentConfiguration configuration) =>
      math.min<int>(level, configuration.maxLevel);

  @override
  Widget build(BuildContext context) {
    final TreeConfiguration treeConfiguration =
        Provider.of<TreeConfiguration>(context);
    final IndentConfiguration configuration =
        treeConfiguration.indentConfiguration;
    return Padding(
      // Combine the base padding with calculated indentation
      padding: configuration.padding.add(
        EdgeInsets.only(
          // Calculate indentation: level × pixels-per-level
          // Constrained by maxLevel configuration
          left: configuration.indentPerLevelBuilder?.call(node) ??
              _constrainLevel(node.level, configuration) *
                  configuration.indentPerLevel,
        ),
      ),
      child: child,
    );
  }
}
