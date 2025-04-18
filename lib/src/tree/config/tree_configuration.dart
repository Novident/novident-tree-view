import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

const int kDefaultExpandDelay = 625;

/// Central configuration class for tree view behavior and operations
///
/// Controls all aspects of tree functionality including:
/// - Node rendering and styling
/// - Drag-and-drop behavior
/// - Scroll interactions
/// - Node lifecycle management
/// - Visual customization
@immutable
class TreeConfiguration {
  final List<NodeComponentBuilder> components;

  /// These are args that usually we want to use in all node builders
  final Map<String, dynamic> extraArgs;

  /// Whether to wrap each row in a RepaintBoundary.
  final bool addRepaintBoundaries;

  /// Determine if we should autoscroll when necessary during
  /// dragging events
  final bool activateAutoScrollFeature;

  /// Callback when hovering over a NodeContainer
  ///
  /// Triggered when a drag operation hovers over a container node
  final void Function(NodeContainer node)? onHoverContainer;

  /// Configuration parameters for scroll behavior
  final ScrollConfigs scrollConfigs;

  /// Settings for drag-and-drop operations
  final DraggableConfigurations draggableConfigurations;

  /// Toggles visibility of child count badges on NodeContainers
  ///
  /// When enabled, displays a count of child nodes in container headers
  final bool shouldDisplayNodeChildrenCount;

  /// Master switch for drag-and-drop functionality
  ///
  /// Set to false to completely disable drag-and-drop features
  final bool activateDragAndDropFeature;

  /// Enables/disables the root insertion area
  ///
  /// When true, shows a special section for adding nodes at the root level (level 0)
  final bool useRootSection;

  /// Placeholder widget for empty root state
  ///
  /// Displayed when the tree has no root nodes and [useRootSection] is enabled
  final Widget? onDetectEmptyRoot;

  /// Hover duration before auto-expanding containers (milliseconds)
  ///
  /// Time delay before automatically expanding NodeContainers during drag operations
  final int onHoverContainerExpansionDelay;

  /// Indentation styling configuration
  final IndentConfiguration indentConfiguration;

  /// Custom drop target area for root-level drops
  ///
  /// Widget displayed when dragging nodes outside normal node boundaries
  final Widget Function(NovDragAndDropDetails<Node> details)?
      rootTargetToDropSection;

  /// Scroll physics for the main tree view
  final ScrollPhysics? physics;

  /// Creates a tree configuration
  const TreeConfiguration({
    required this.components,
    required this.draggableConfigurations,
    this.indentConfiguration = const IndentConfiguration.basic(),
    this.onHoverContainer,
    this.scrollConfigs = const ScrollConfigs(),
    this.extraArgs = const <String, dynamic>{},
    this.activateDragAndDropFeature = true,
    this.addRepaintBoundaries = false,
    this.activateAutoScrollFeature = false,
    this.useRootSection = false,
    this.shouldDisplayNodeChildrenCount = false,
    this.onHoverContainerExpansionDelay = kDefaultExpandDelay,
    this.rootTargetToDropSection,
    this.physics,
    this.onDetectEmptyRoot,
  });

  /// Creates a modified copy of the configuration
  ///
  /// Any parameter not specified will retain its original value
  TreeConfiguration copyWith({
    List<NodeComponentBuilder>? components,
    Map<String, dynamic>? extraArgs,
    void Function(Node node)? onHoverContainer,
    ScrollConfigs? scrollConfigs,
    DraggableConfigurations? draggableConfigurations,
    bool? shouldDisplayNodeChildrenCount,
    bool? activateDragAndDropFeature,
    bool? useRootSection,
    bool? activateAutoScrollFeature,
    Widget? onDetectEmptyRoot,
    int? onHoverContainerExpansionDelay,
    IndentConfiguration? indentConfiguration,
    Widget Function(NovDragAndDropDetails<Node> details)?
        rootTargetToDropSection,
    ScrollPhysics? physics,
  }) {
    return TreeConfiguration(
      onHoverContainer: onHoverContainer ?? this.onHoverContainer,
      components: components ?? this.components,
      extraArgs: extraArgs ?? this.extraArgs,
      scrollConfigs: scrollConfigs ?? this.scrollConfigs,
      draggableConfigurations:
          draggableConfigurations ?? this.draggableConfigurations,
      shouldDisplayNodeChildrenCount:
          shouldDisplayNodeChildrenCount ?? this.shouldDisplayNodeChildrenCount,
      activateDragAndDropFeature:
          activateDragAndDropFeature ?? this.activateDragAndDropFeature,
      useRootSection: useRootSection ?? this.useRootSection,
      onDetectEmptyRoot: onDetectEmptyRoot ?? this.onDetectEmptyRoot,
      onHoverContainerExpansionDelay:
          onHoverContainerExpansionDelay ?? this.onHoverContainerExpansionDelay,
      indentConfiguration: indentConfiguration ?? this.indentConfiguration,
      rootTargetToDropSection:
          rootTargetToDropSection ?? this.rootTargetToDropSection,
      physics: physics ?? this.physics,
      activateAutoScrollFeature:
          activateDragAndDropFeature ?? this.activateAutoScrollFeature,
    );
  }

  @override
  bool operator ==(covariant TreeConfiguration other) {
    if (identical(this, other)) return true;

    return other.onHoverContainer == onHoverContainer &&
        other.scrollConfigs == scrollConfigs &&
        other.activateAutoScrollFeature == activateAutoScrollFeature &&
        other.draggableConfigurations == draggableConfigurations &&
        other.shouldDisplayNodeChildrenCount ==
            shouldDisplayNodeChildrenCount &&
        other.activateDragAndDropFeature == activateDragAndDropFeature &&
        other.useRootSection == useRootSection &&
        other.onDetectEmptyRoot == onDetectEmptyRoot &&
        other.onHoverContainerExpansionDelay ==
            onHoverContainerExpansionDelay &&
        other.indentConfiguration == indentConfiguration &&
        other.rootTargetToDropSection == rootTargetToDropSection &&
        listEquals<NodeComponentBuilder>(other.components, components) &&
        mapEquals<String, dynamic>(other.extraArgs, extraArgs) &&
        other.physics == physics;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      components,
      activateAutoScrollFeature,
      extraArgs,
      onHoverContainer,
      scrollConfigs,
      draggableConfigurations,
      shouldDisplayNodeChildrenCount,
      activateDragAndDropFeature,
      useRootSection,
      onDetectEmptyRoot,
      onHoverContainerExpansionDelay,
      indentConfiguration,
      rootTargetToDropSection,
      physics,
    ]);
  }
}
