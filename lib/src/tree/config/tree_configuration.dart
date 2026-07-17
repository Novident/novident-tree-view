import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

typedef AnimatedWidgetBuilder = Widget Function(
    Animation<double>, Node node, Widget child);

/// Central configuration for tree view behaviour and appearance.
///
/// ## Simple usage
/// ```dart
/// TreeConfiguration(
///   builders: [FolderBuilder(), FileBuilder()],
/// )
/// ```
///
/// ## With drag feedback and indentation
/// ```dart
/// TreeConfiguration(
///   builders: [...],
///   indent: 14,
///   dragConfig: DraggableConfigurations.simple(
///     feedback: (node, ctx) => MyDragCard(node: node),
///   ),
/// )
/// ```
///
/// ## Full control
/// ```dart
/// TreeConfiguration(
///   builders: [...],
///   indent: 14,
///   dragConfig: DraggableConfigurations(
///     buildDragFeedbackWidget: ...,
///     preferLongPressDraggable: true,
///     axis: Axis.vertical,
///   ),
///   shrinkWrap: true,
///   physics: NeverScrollableScrollPhysics(),
///   scrollController: myController,
///   emptyPlaceholder: (context) => Text('Nothing here'),
///   sharedData: {'theme': myTheme},
///   activateDragAndDropFeature: true,
///   addRepaintBoundaries: false,
/// )
/// ```
@immutable
final class TreeConfiguration {
  /// Component builders that render nodes.
  ///
  /// At least one builder is required. The first builder whose
  /// [NodeComponentBuilder.validate] returns `true` wins.
  final List<NodeComponentBuilder> builders;

  /// Drag-and-drop configuration.
  ///
  /// Defaults to a minimal configuration that shows no visible feedback.
  /// Use [DraggableConfigurations.simple] for a quick custom feedback
  /// widget, or the full constructor for complete control.
  final DraggableConfigurations dragConfig;

  /// Master switch for drag-and-drop.
  ///
  /// When `false` every node is rendered as plain content — no
  /// [Draggable] or [DragTarget] wrapping.
  final bool activateDragAndDropFeature;

  /// Indentation in logical pixels per tree level.
  ///
  /// Shorthand for `IndentConfiguration.basic(indentPerLevel: …)`.
  /// Use [indentConfiguration] for dynamic per-node indentation.
  final double indent;

  /// Full indentation configuration.
  ///
  /// When provided, [indent] is ignored. Use this for dynamic
  /// per-node indentation via [IndentConfiguration.indentPerLevelBuilder].
  final IndentConfiguration? indentConfiguration;

  /// Widget shown when the root has no children.
  final Widget? Function(BuildContext)? emptyPlaceholder;

  /// Whether each row is wrapped in a [RepaintBoundary].
  final bool addRepaintBoundaries;

  /// Whether the tree list should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Scroll physics for the tree.
  final ScrollPhysics physics;

  /// Controller for the main scroll view.
  final ScrollController? scrollController;

  /// The size of the top zone of every drop target (default: 7 logical pixels)
  final double topZoneHeight;

  /// The size of the bottom zone of every drop target (default: 5.5 logical pixels)
  final double bottomZoneHeight;

  /// Full list-view configuration (advanced override).
  ///
  /// When provided, [shrinkWrap], [physics] and [scrollController]
  /// are ignored in favour of this object.
  final ListViewConfigurations? listView;

  /// Arbitrary data shared with every [NodeComponentBuilder] via
  /// [ComponentContext.sharedData].
  final Map<String, dynamic> sharedData;

  /// Full list-view configuration.
  ListViewConfigurations get treeListViewConfigurations =>
      listView ??
      ListViewConfigurations(
        shrinkWrap: shrinkWrap,
        physics: physics,
        scrollController: scrollController,
      );

  /// Effective indentation configuration.
  ///
  /// Returns [indentConfiguration] when provided, otherwise derives a
  /// basic config from [indent].
  IndentConfiguration get effectiveIndentConfig =>
      indentConfiguration ?? IndentConfiguration.basic(indentPerLevel: indent);

  TreeConfiguration({
    required this.builders,
    DraggableConfigurations? dragConfig,
    this.indent = 20,
    this.indentConfiguration,
    this.activateDragAndDropFeature = true,
    this.addRepaintBoundaries = false,
    this.emptyPlaceholder,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.scrollController,
    this.listView,
    this.sharedData = const <String, dynamic>{},
    this.topZoneHeight = 7,
    this.bottomZoneHeight = 5.5,
  })  : dragConfig = dragConfig ?? _defaultDragConfig,
        assert(
          builders.isNotEmpty,
          'At least one NodeComponentBuilder is required.',
        );

  TreeConfiguration copyWith({
    List<NodeComponentBuilder>? builders,
    DraggableConfigurations? dragConfig,
    double? indent,
    double? topZoneHeight,
    double? bottomZoneHeight,
    IndentConfiguration? indentConfiguration,
    Map<String, dynamic>? sharedData,
    bool? activateDragAndDropFeature,
    bool? addRepaintBoundaries,
    Widget? Function(BuildContext)? emptyPlaceholder,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    ScrollController? scrollController,
    ListViewConfigurations? listView,
  }) {
    return TreeConfiguration(
      builders: builders ?? this.builders,
      dragConfig: dragConfig ?? this.dragConfig,
      indent: indent ?? this.indent,
      indentConfiguration: indentConfiguration ?? this.indentConfiguration,
      sharedData: sharedData ?? this.sharedData,
      activateDragAndDropFeature:
          activateDragAndDropFeature ?? this.activateDragAndDropFeature,
      addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
      emptyPlaceholder: emptyPlaceholder ?? this.emptyPlaceholder,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
      scrollController: scrollController ?? this.scrollController,
      listView: listView ?? this.listView,
      topZoneHeight: topZoneHeight ?? this.topZoneHeight,
      bottomZoneHeight: bottomZoneHeight ?? this.bottomZoneHeight,
    );
  }

  @override
  bool operator ==(covariant TreeConfiguration other) {
    if (identical(this, other)) return true;
    return other.dragConfig == dragConfig &&
        other.listView == listView &&
        other.activateDragAndDropFeature == activateDragAndDropFeature &&
        other.emptyPlaceholder == emptyPlaceholder &&
        other.topZoneHeight == topZoneHeight &&
        other.bottomZoneHeight == bottomZoneHeight &&
        other.indent == indent &&
        listEquals<NodeComponentBuilder>(other.builders, builders) &&
        mapEquals<String, dynamic>(other.sharedData, sharedData);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        builders,
        sharedData,
        dragConfig,
        listView,
        activateDragAndDropFeature,
        topZoneHeight.hashCode,
        bottomZoneHeight.hashCode,
        emptyPlaceholder,
        indent,
      ]);

  static const DraggableConfigurations _defaultDragConfig =
      DraggableConfigurations(
    buildDragFeedbackWidget: _defaultFeedback,
    expandOnHover: true,
  );

  static Widget _defaultFeedback(Node node, BuildContext context) =>
      const SizedBox.shrink();
}
