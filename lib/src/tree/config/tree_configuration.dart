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
  /// Builder function that creates visual representations for nodes
  ///
  /// [node]: The node to visualize
  /// [details]: Current drag-and-drop operation details (null when not dragging)
  final Widget Function(
          Node node, BuildContext context, NovDragAndDropDetails<Node>? details)
      nodeBuilder;

  /// Whether to wrap each row in a RepaintBoundary.
  final bool addRepaintBoundaries;

  /// Builder function that creates the configuration for nodes
  ///
  /// Usually used to give to the [Node] the tappable capability
  final NodeConfiguration Function(Node node)? nodeConfigBuilder;

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

  /// Key generator for node widget state preservation
  ///
  /// Generates unique keys to maintain node state across rebuilds
  final PageStorageKey<String>? Function(Node node)? nodeWidgetKey;

  /// Custom builder for node children layouts
  ///
  /// Overrides default child rendering with custom layouts. Receives:
  /// [parent]: The parent container (null for root)
  /// [children]: List of child nodes to display
  final Widget Function(NodeContainer? parent, List<Node> children)?
      buildCustomChildren;

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

  /// Gesture handler factory for drag operations
  ///
  /// Creates drag gesture handlers for individual nodes
  final NodeDragGestures Function(Node) nodeDragGestures;

  /// Creates a tree configuration
  const TreeConfiguration({
    required this.nodeBuilder,
    required this.activateDragAndDropFeature,
    required this.indentConfiguration,
    required this.nodeDragGestures,
    required this.onHoverContainer,
    required this.scrollConfigs,
    required this.draggableConfigurations,
    this.addRepaintBoundaries = false,
    this.activateAutoScrollFeature = false,
    this.nodeConfigBuilder,
    this.nodeWidgetKey,
    this.useRootSection = false,
    this.shouldDisplayNodeChildrenCount = false,
    this.onHoverContainerExpansionDelay = kDefaultExpandDelay,
    this.rootTargetToDropSection,
    this.physics,
    this.buildCustomChildren,
    this.onDetectEmptyRoot,
  });

  /// Creates a modified copy of the configuration
  ///
  /// Any parameter not specified will retain its original value
  TreeConfiguration copyWith({
    Widget Function(Node node, BuildContext context,
            NovDragAndDropDetails<Node>? details)?
        nodeBuilder,
    void Function(Node node)? onHoverContainer,
    ScrollConfigs? scrollConfigs,
    DraggableConfigurations? draggableConfigurations,
    bool? shouldDisplayNodeChildrenCount,
    bool? activateDragAndDropFeature,
    bool? useRootSection,
    bool? activateAutoScrollFeature,
    NodeConfiguration Function(Node node)? nodeConfigBuilder,
    PageStorageKey<String>? Function(Node node)? nodeWidgetKey,
    Widget Function(Node? parent, List<Node> children)? buildCustomChildren,
    Widget? onDetectEmptyRoot,
    int? onHoverContainerExpansionDelay,
    IndentConfiguration? indentConfiguration,
    Widget Function(NovDragAndDropDetails<Node> details)?
        rootTargetToDropSection,
    ScrollPhysics? physics,
    NodeDragGestures Function(Node)? nodeDragGestures,
  }) {
    return TreeConfiguration(
      nodeBuilder: nodeBuilder ?? this.nodeBuilder,
      onHoverContainer: onHoverContainer ?? this.onHoverContainer,
      scrollConfigs: scrollConfigs ?? this.scrollConfigs,
      draggableConfigurations:
          draggableConfigurations ?? this.draggableConfigurations,
      shouldDisplayNodeChildrenCount:
          shouldDisplayNodeChildrenCount ?? this.shouldDisplayNodeChildrenCount,
      activateDragAndDropFeature:
          activateDragAndDropFeature ?? this.activateDragAndDropFeature,
      useRootSection: useRootSection ?? this.useRootSection,
      nodeWidgetKey: nodeWidgetKey ?? this.nodeWidgetKey,
      buildCustomChildren: buildCustomChildren ?? this.buildCustomChildren,
      onDetectEmptyRoot: onDetectEmptyRoot ?? this.onDetectEmptyRoot,
      onHoverContainerExpansionDelay:
          onHoverContainerExpansionDelay ?? this.onHoverContainerExpansionDelay,
      indentConfiguration: indentConfiguration ?? this.indentConfiguration,
      rootTargetToDropSection:
          rootTargetToDropSection ?? this.rootTargetToDropSection,
      physics: physics ?? this.physics,
      nodeDragGestures: nodeDragGestures ?? this.nodeDragGestures,
      activateAutoScrollFeature:
          activateDragAndDropFeature ?? this.activateAutoScrollFeature,
      nodeConfigBuilder: nodeConfigBuilder ?? this.nodeConfigBuilder,
    );
  }

  @override
  bool operator ==(covariant TreeConfiguration other) {
    if (identical(this, other)) return true;

    return other.nodeBuilder == nodeBuilder &&
        other.onHoverContainer == onHoverContainer &&
        other.scrollConfigs == scrollConfigs &&
        other.activateAutoScrollFeature == activateAutoScrollFeature &&
        other.nodeConfigBuilder == nodeConfigBuilder &&
        other.draggableConfigurations == draggableConfigurations &&
        other.shouldDisplayNodeChildrenCount ==
            shouldDisplayNodeChildrenCount &&
        other.activateDragAndDropFeature == activateDragAndDropFeature &&
        other.useRootSection == useRootSection &&
        other.nodeWidgetKey == nodeWidgetKey &&
        other.buildCustomChildren == buildCustomChildren &&
        other.onDetectEmptyRoot == onDetectEmptyRoot &&
        other.onHoverContainerExpansionDelay ==
            onHoverContainerExpansionDelay &&
        other.indentConfiguration == indentConfiguration &&
        other.rootTargetToDropSection == rootTargetToDropSection &&
        other.physics == physics &&
        other.nodeDragGestures == nodeDragGestures;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      nodeBuilder,
      onHoverContainer,
      scrollConfigs,
      activateAutoScrollFeature.hashCode,
      nodeConfigBuilder.hashCode,
      draggableConfigurations,
      shouldDisplayNodeChildrenCount,
      activateDragAndDropFeature,
      useRootSection,
      nodeWidgetKey,
      buildCustomChildren,
      onDetectEmptyRoot,
      onHoverContainerExpansionDelay,
      indentConfiguration,
      rootTargetToDropSection,
      physics,
      nodeDragGestures,
    ]);
  }
}
