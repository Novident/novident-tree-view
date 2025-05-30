import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

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
  @Deprecated(
    'onHoverContainer is not being used, '
    'and nWas replace by onTryExpand method into '
    'NodeComponentBuilder base class.',
  )
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
  @Deprecated(
    'onHoverContainerExpansionDelay is not used, and was '
    'replaced by onHoverCallDelay into NodeComponentBuilder class',
  )
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
    this.onDetectEmptyRoot,
  })  : onHoverContainerExpansionDelay = -1,
        animatedWrapper = null,
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
    this.onDetectEmptyRoot,
  })  : onHoverContainerExpansionDelay = -1,
        useAnimatedLists = true,
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
    IndentConfiguration? indentConfiguration,
    AnimatedWidgetBuilder? animatedWrapper,
    AnimatedWidgetBuilder? onDeleteAnimationWrapper,
    Widget Function(NovDragAndDropDetails<Node> details)?
        rootTargetToDropSection,
  }) {
    if (useAnimatedLists) {
      return TreeConfiguration.animated(
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
        indentConfiguration: indentConfiguration ?? this.indentConfiguration,
      );
    }
    return TreeConfiguration(
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
      indentConfiguration: indentConfiguration ?? this.indentConfiguration,
    );
  }

  @override
  bool operator ==(covariant TreeConfiguration other) {
    if (identical(this, other)) return true;

    return other.draggableConfigurations == draggableConfigurations &&
        other.treeListViewConfigurations == treeListViewConfigurations &&
        other.activateDragAndDropFeature == activateDragAndDropFeature &&
        other.onDetectEmptyRoot == onDetectEmptyRoot &&
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
      treeListViewConfigurations,
      draggableConfigurations,
      activateDragAndDropFeature,
      onDetectEmptyRoot,
      indentConfiguration,
    ]);
  }
}
