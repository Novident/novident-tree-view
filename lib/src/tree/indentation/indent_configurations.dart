import 'package:flutter/rendering.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// Configuration class that defines how tree nodes should be indented
///
/// This class provides parameters to control:
/// - The amount of indentation per level
/// - Maximum indentation level
/// - Additional padding around nodes
class IndentConfiguration {
  /// Largest possible integer value used to represent unlimited indentation levels
  static const int largestIndentAccepted = -1 >>> 1;

  /// The amount of horizontal space (in pixels) to indent per level in the tree
  final double indentPerLevel;

  /// The amount of horizontal space (in pixels) to indent per level in the tree
  /// that can be dynamically builded if it's needed
  ///
  /// When the returned value is null, then indentPerLevel will be used
  final double? Function(Node node)? indentPerLevelBuilder;

  /// Additional padding to apply around the node content
  final EdgeInsetsGeometry padding;

  /// The maximum level depth that will be indented
  ///
  /// Nodes deeper than this level will be indented as if they were at this level
  final int maxLevel;

  /// Creates an indentation configuration
  ///
  /// [indentPerLevel]: Space per level (default 40px)
  /// [indentPerLevelBuilder]: Space per level that can be builded dynamically
  /// [maxLevel]: Maximum indentation level (default unlimited)
  /// [padding]: Additional padding around nodes (default zero)
  IndentConfiguration({
    this.indentPerLevel = 30,
    this.indentPerLevelBuilder,
    this.maxLevel = largestIndentAccepted,
    this.padding = EdgeInsets.zero,
  });

  /// Creates a copy of this configuration with the specified fields replaced
  ///
  /// Any parameter not specified will maintain its current value
  IndentConfiguration copyWith({
    double? indentPerLevel,
    double? Function(Node)? indentPerLevelBuilder,
    EdgeInsetsGeometry? padding,
    int? maxLevel,
  }) {
    return IndentConfiguration(
      indentPerLevel: indentPerLevel ?? this.indentPerLevel,
      indentPerLevelBuilder:
          indentPerLevelBuilder ?? this.indentPerLevelBuilder,
      padding: padding ?? this.padding,
      maxLevel: maxLevel ?? this.maxLevel,
    );
  }

  @override
  int get hashCode =>
      Object.hash(indentPerLevel, padding, maxLevel, indentPerLevelBuilder);

  @override
  operator ==(covariant IndentConfiguration other) {
    if (identical(other, this)) return true;

    return other.indentPerLevelBuilder == indentPerLevelBuilder &&
        other.indentPerLevel == indentPerLevel &&
        other.padding == padding &&
        other.maxLevel == maxLevel;
  }
}
