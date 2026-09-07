import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart' hide Node;
import 'package:novident_nodes/novident_nodes.dart';
import 'package:novident_split_view/novident_split_view.dart';

import '../drawer/tree_view_drawer.dart';
import '../editor/editor_configuration.dart';
import '../editor/editor_pane.dart';

/// Desktop workspace: binder on the left, a [NovSplitView] on the right.
///
/// Dragging a document from the binder over the split area shows the
/// zone shadow and splits at the drop position — as many editors as
/// needed, each one with isolated state (see [EditorPane]).
class DesktopTreeViewExample extends StatefulWidget {
  final TreeController controller;
  const DesktopTreeViewExample({
    super.key,
    required this.controller,
  });

  @override
  State<DesktopTreeViewExample> createState() => _DesktopTreeViewExampleState();
}

class _DesktopTreeViewExampleState extends State<DesktopTreeViewExample> {
  late final TreeController treeController;
  final SplitViewController _splitController = SplitViewController();
  late final SplitViewConfiguration _configuration;
  final FocusedEditorNotifier _toolbarNotifier = FocusedEditorNotifier();

  @override
  void initState() {
    super.initState();
    treeController = widget.controller
      ..selectNode(widget.controller.root.atPath(<int>[0, 0]));
    final File? initial = treeController.selectedFile;
    if (initial != null) {
      _splitController.open(initial.id);
    }
    treeController.selection.addListener(_onSelectionChanged);
    treeController.root.addListener(_onTreeChanged);
    _configuration = SplitViewConfiguration(
      paneBuilder: _buildPane,
      emptyPlaceholder: _buildEmptySplitTarget,
      onWillAcceptSplit: (SplitDragAndDropDetails<Node> details) =>
          details.draggedNode is File,
    );
  }

  @override
  void dispose() {
    treeController.selection.removeListener(_onSelectionChanged);
    treeController.root.removeListener(_onTreeChanged);
    treeController
      ..invalidateSelection()
      ..dispose();
    _splitController.dispose();
    _toolbarNotifier.dispose();
    super.dispose();
  }

  /// Selecting a document in the binder opens it (or focuses its first
  /// pane when it is already visible). Buffers are never closed by
  /// selection changes: that is the whole point of the split view.
  void _onSelectionChanged() {
    if (!mounted) return;
    final File? file = treeController.selectedFile;
    if (file == null) return;
    final (int, int)? location = _splitController.locate(file.id);
    if (location == null) {
      _splitController.open(file.id);
      return;
    }
    _splitController.focusPane(location.$1, location.$2);
  }

  /// Tree mutations (renames, deletions from the trash target...) must
  /// refresh the panes: they resolve their [File] by id on each build.
  void _onTreeChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildPane(BuildContext context, PaneContext pane) {
    final Node? node = treeController.root.visitAllNodes(
      shouldGetNode: (Node node) => node.id == pane.nodeId,
    );
    if (node is! File) {
      return _buildMissingDocumentPane(pane);
    }
    return EditorPane(
      key: ValueKey(node.id),
      file: node,
      isFocused: pane.isFocused,
      toolbarNotifier: _toolbarNotifier,
      styles: kEditorStyles,
    );
  }

  /// Shown when the document behind a pane was deleted from the tree.
  Widget _buildMissingDocumentPane(PaneContext pane) {
    return ColoredBox(
      color: kWorkspaceBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              CupertinoIcons.doc_text,
              size: 34,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              'This document no longer exists',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => _splitController.closePane(
                pane.columnIndex,
                pane.paneIndex,
              ),
              child: const Text('Close pane'),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty split view: a full-area drop target so the very first
  /// document can also be opened by drag and drop.
  Widget _buildEmptySplitTarget(BuildContext context) {
    return DragTarget<Node>(
      onWillAcceptWithDetails: (DragTargetDetails<Node> details) =>
          details.data is File,
      onAcceptWithDetails: (DragTargetDetails<Node> details) =>
          _splitController.open(details.data.id),
      builder: (
        BuildContext context,
        List<Node?> candidateData,
        List<dynamic> rejectedData,
      ) {
        final Node? candidate =
            candidateData.isEmpty ? null : candidateData.first;
        if (candidate is File) {
          return _buildOpenFileVeil(context, candidate);
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                CupertinoIcons.doc_text,
                size: 44,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 12),
              Text(
                'There\'s no File to watch...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a document in the binder, or drag one here',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Veil + `Open "<file>"` card shown while a document hovers the
  /// empty split area.
  Widget _buildOpenFileVeil(BuildContext context, File candidate) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x40000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent, width: 2),
      ),
      child: Center(
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(CupertinoIcons.doc_text_fill, size: 20, color: accent),
                const SizedBox(width: 10),
                Text(
                  'Open "${candidate.name}"',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double binderWidth = (MediaQuery.sizeOf(context).width * 0.30)
        .clamp(240.0, 320.0)
        .toDouble();
    return Scaffold(
      backgroundColor: kWorkspaceBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: binderWidth,
            child: RepaintBoundary(
              child: TreeViewDrawer(controller: widget.controller),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ValueListenableBuilder<EditorState?>(
                  valueListenable: _toolbarNotifier,
                  builder: (
                    context,
                    editorState,
                    _,
                  ) {
                    return LayoutBuilder(builder: (
                      context,
                      constraints,
                    ) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: NovidentStaticToolbar(
                          items: kDesktopToolbarItems,
                          editorState: editorState,
                          stylesConfig: kEditorStyles,
                          showWhenNoSelection: true,
                        ),
                      );
                    });
                  },
                ),
                Expanded(
                  child: NovSplitView(
                    controller: _splitController,
                    configuration: _configuration,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
