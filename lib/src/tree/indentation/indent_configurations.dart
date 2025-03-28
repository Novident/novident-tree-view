import 'package:flutter/rendering.dart';

/// Largest possible integer value used to represent unlimited indentation levels
const int _largestIndentPermitted = -1 >>> 1;

/// Configuration class that defines how tree nodes should be indented
///
/// This class provides parameters to control:
/// - The amount of indentation per level
/// - Maximum indentation level
/// - Additional padding around nodes
class IndentConfiguration {
  /// The amount of horizontal space (in pixels) to indent per level in the tree
  final double indentPerLevel;

  /// Additional padding to apply around the node content
  final EdgeInsetsGeometry padding;

  /// The maximum level depth that will be indented
  ///
  /// Nodes deeper than this level will be indented as if they were at this level
  final int maxLevel;

  /// Creates an indentation configuration
  ///
  /// [indentPerLevel]: Space per level (default 40px)
  /// [maxLevel]: Maximum indentation level (default unlimited)
  /// [padding]: Additional padding around nodes (default zero)
  IndentConfiguration({
    this.indentPerLevel = 40,
    this.maxLevel = _largestIndentPermitted,
    this.padding = EdgeInsets.zero,
  });

  /// Creates a copy of this configuration with the specified fields replaced
  ///
  /// Any parameter not specified will maintain its current value
  IndentConfiguration copyWith({
    double? indentPerLevel,
    EdgeInsetsGeometry? padding,
    int? maxLevel,
  }) {
    return IndentConfiguration(
      indentPerLevel: indentPerLevel ?? this.indentPerLevel,
      padding: padding ?? this.padding,
      maxLevel: maxLevel ?? this.maxLevel,
    );
  }

  @override
  int get hashCode => Object.hash(indentPerLevel, padding, maxLevel);

  @override
  operator ==(covariant IndentConfiguration other) {
    if (identical(other, this)) return true;

    return other.indentPerLevel == indentPerLevel &&
        other.padding == padding &&
        other.maxLevel == maxLevel;
  }
}
