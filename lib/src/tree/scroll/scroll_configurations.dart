/// Configuration class for controlling scroll behavior in the tree view
///
/// This class provides parameters to customize how scrolling behaves,
/// particularly during drag-and-drop operations when auto-scrolling is needed.
class ScrollConfigs {
  /// Sensitivity threshold for triggering auto-scroll during drag operations
  ///
  /// Represents the distance in pixels from the edge of the scrollable area
  /// where auto-scrolling should activate when dragging a node.
  ///
  /// - Smaller values make auto-scrolling trigger closer to the edge
  /// - Larger values make auto-scrolling trigger further from the edge
  /// - Default value: 100.0 pixels
  ///
  /// Example:
  /// ```dart
  /// ScrollConfigs(autoScrollSensitivity: 80.0) // More sensitive scrolling
  /// ```
  final double autoScrollSensitivity;

  /// Creates a scroll configuration
  ///
  /// [autoScrollSensitivity]: Controls how close to the edge auto-scrolling
  /// activates during drag operations (default: 100.0)
  const ScrollConfigs({
    this.autoScrollSensitivity = 100.0,
  });

  /// Creates a copy of this configuration with modified values
  ///
  /// [autoScrollSensitivity]: If provided, replaces the current sensitivity value
  ///
  /// Returns a new [ScrollConfigs] instance with the updated values
  ScrollConfigs copyWith({
    double? autoScrollSensitivity,
  }) {
    return ScrollConfigs(
      autoScrollSensitivity:
          autoScrollSensitivity ?? this.autoScrollSensitivity,
    );
  }

  @override
  bool operator ==(covariant ScrollConfigs other) {
    if (identical(this, other)) return true;

    return other.autoScrollSensitivity == autoScrollSensitivity;
  }

  @override
  int get hashCode => autoScrollSensitivity.hashCode;
}
