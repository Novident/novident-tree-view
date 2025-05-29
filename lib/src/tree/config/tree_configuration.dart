import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

const int _kDefaultExpandDelay = 625;

typedef AnimatedWidgetBuilder = Widget Function(
    Animation<double>, Node node, Widget child);

/// Central configuration class for tree view behavior and operations
@immutable
final class TreeConfiguration {
  final List<NodeComponentBuilder> components;
  final ListViewConfigurations treeListViewConfigurations;

  final AnimatedWidgetBuilder? animatedWrapper;
  final AnimatedWidgetBuilder? onDeleteAnimationWrapper;
  final bool useAnimatedLists;

  /// These are args that usually we want to use in all node builders
  final Map<String, dynamic> extraArgs;

  /// Whether to wrap each row in a RepaintBoundary.
  final bool addRepaintBoundaries;

  /// Callback when hovering over a NodeContainer
  ///
  /// Triggered when a drag operation hovers over a container node
  final void Function(NodeContainer node)? onHoverContainer;

  /// Settings for drag-and-drop operations
  final DraggableConfigurations draggableConfigurations;

  /// Master switch for drag-and-drop functionality
  ///
  /// Set to false to completely disable drag-and-drop features
  final bool activateDragAndDropFeature;

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

  /// Creates a tree configuration
  TreeConfiguration({
    required this.components,
    required this.draggableConfigurations,
    this.treeListViewConfigurations = const ListViewConfigurations(),
    this.indentConfiguration = const IndentConfiguration.basic(),
    this.onHoverContainer,
    this.extraArgs = const <String, dynamic>{},
    this.activateDragAndDropFeature = true,
    this.addRepaintBoundaries = false,
    this.onHoverContainerExpansionDelay = _kDefaultExpandDelay,
    this.onDetectEmptyRoot,
  })  : animatedWrapper = null,
        onDeleteAnimationWrapper = null,
        useAnimatedLists = false,
        assert(
          components.isNotEmpty,
          'Nodes cannot be rendered if there\'s no builders for them',
        );

  /// Creates a tree configuration
  TreeConfiguration.animated({
    required this.components,
    required this.draggableConfigurations,
    required this.animatedWrapper,
    required this.onDeleteAnimationWrapper,
    this.treeListViewConfigurations = const ListViewConfigurations(),
    this.indentConfiguration = const IndentConfiguration.basic(),
    this.onHoverContainer,
    this.extraArgs = const <String, dynamic>{},
    this.activateDragAndDropFeature = true,
    this.addRepaintBoundaries = false,
    this.onHoverContainerExpansionDelay = _kDefaultExpandDelay,
    this.onDetectEmptyRoot,
  })  : useAnimatedLists = true,
        assert(animatedWrapper != null, 'animatedWrapper cannot be nullable'),
        assert(onDeleteAnimationWrapper != null,
            'onDeleteAnimationWrapper cannot be nullable'),
        assert(
          components.isNotEmpty,
          'Nodes cannot be rendered if there\'s no builders for them',
        );

  /// Creates a modified copy of the configuration
  ///
  /// Any parameter not specified will retain its original value
  TreeConfiguration copyWith({
    List<NodeComponentBuilder>? components,
    ListViewConfigurations? treeListViewConfigurations,
    Map<String, dynamic>? extraArgs,
    void Function(Node node)? onHoverContainer,
    DraggableConfigurations? draggableConfigurations,
    bool? activateDragAndDropFeature,
    bool? addRepaintBoundaries,
    Widget? onDetectEmptyRoot,
    int? onHoverContainerExpansionDelay,
    IndentConfiguration? indentConfiguration,
    AnimatedWidgetBuilder? animatedWrapper,
    AnimatedWidgetBuilder? onDeleteAnimationWrapper,
    Widget Function(NovDragAndDropDetails<Node> details)?
        rootTargetToDropSection,
  }) {
    if (useAnimatedLists) {
      return TreeConfiguration.animated(
        onHoverContainer: onHoverContainer ?? this.onHoverContainer,
        animatedWrapper: animatedWrapper ?? this.animatedWrapper,
        onDeleteAnimationWrapper:
            onDeleteAnimationWrapper ?? this.onDeleteAnimationWrapper,
        components: components ?? this.components,
        treeListViewConfigurations:
            treeListViewConfigurations ?? this.treeListViewConfigurations,
        addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
        extraArgs: extraArgs ?? this.extraArgs,
        draggableConfigurations:
            draggableConfigurations ?? this.draggableConfigurations,
        activateDragAndDropFeature:
            activateDragAndDropFeature ?? this.activateDragAndDropFeature,
        onDetectEmptyRoot: onDetectEmptyRoot ?? this.onDetectEmptyRoot,
        onHoverContainerExpansionDelay: onHoverContainerExpansionDelay ??
            this.onHoverContainerExpansionDelay,
        indentConfiguration: indentConfiguration ?? this.indentConfiguration,
      );
    }
    return TreeConfiguration(
      onHoverContainer: onHoverContainer ?? this.onHoverContainer,
      components: components ?? this.components,
      treeListViewConfigurations:
          treeListViewConfigurations ?? this.treeListViewConfigurations,
      addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
      extraArgs: extraArgs ?? this.extraArgs,
      draggableConfigurations:
          draggableConfigurations ?? this.draggableConfigurations,
      activateDragAndDropFeature:
          activateDragAndDropFeature ?? this.activateDragAndDropFeature,
      onDetectEmptyRoot: onDetectEmptyRoot ?? this.onDetectEmptyRoot,
      onHoverContainerExpansionDelay:
          onHoverContainerExpansionDelay ?? this.onHoverContainerExpansionDelay,
      indentConfiguration: indentConfiguration ?? this.indentConfiguration,
    );
  }

  @override
  bool operator ==(covariant TreeConfiguration other) {
    if (identical(this, other)) return true;

    return other.onHoverContainer == onHoverContainer &&
        other.draggableConfigurations == draggableConfigurations &&
        other.treeListViewConfigurations == treeListViewConfigurations &&
        other.activateDragAndDropFeature == activateDragAndDropFeature &&
        other.onDetectEmptyRoot == onDetectEmptyRoot &&
        other.onHoverContainerExpansionDelay ==
            onHoverContainerExpansionDelay &&
        other.indentConfiguration == indentConfiguration &&
        other.animatedWrapper == animatedWrapper &&
        other.onDeleteAnimationWrapper == onDeleteAnimationWrapper &&
        other.useAnimatedLists == useAnimatedLists &&
        listEquals<NodeComponentBuilder>(other.components, components) &&
        mapEquals<String, dynamic>(other.extraArgs, extraArgs);
  }

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      components,
      extraArgs,
      animatedWrapper,
      onDeleteAnimationWrapper,
      useAnimatedLists,
      onHoverContainer,
      treeListViewConfigurations,
      draggableConfigurations,
      activateDragAndDropFeature,
      onDetectEmptyRoot,
      onHoverContainerExpansionDelay,
      indentConfiguration,
    ]);
  }
}
