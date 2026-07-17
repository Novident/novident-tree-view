import 'dart:convert';

import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Node;
import 'package:flutter_quill/quill_delta.dart';
import 'package:novident_nodes/novident_nodes.dart';

import '../drawer/tree_view_drawer.dart';
import '../editor/my_editor.dart';

/// Scrivener-like workspace colors.
const Color _kWorkspaceBackground = Color(0xFFECECEC);
const Color _kPaneDivider = Color(0xFFD6D6D6);

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
  final QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late TreeController treeController;
  final ValueNotifier<bool> _isDraggingAboveEditor = ValueNotifier<bool>(false);
  bool _showNoFileToWatch = false;
  File? _lastNode;
  bool _onChangeCalledFromSelectionHandler = false;
  Delta oldVersion = Delta();

  @override
  void initState() {
    treeController = widget.controller
      ..selectNode(widget.controller.root.atPath([1, 0]));
    _lastNode = treeController.selection.value! as File;
    _loadContent();
    super.initState();
  }

  @override
  void dispose() {
    treeController
      ..invalidateSelection()
      ..dispose();
    _isDraggingAboveEditor.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadContent() {
    var content = (_lastNode as File).content;
    if (content.isEmpty) content = '[{"insert":"\\n"}]';
    final delta = Delta.fromJson(
      jsonDecode(content),
    );
    oldVersion = delta;
    _controller.document = Document.fromDelta(delta);
    _onChangeCalledFromSelectionHandler = false;
  }

  void _onRemoveCurrentSelection() {
    _lastNode = null;
    _showNoFileToWatch = true;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  void _handleOnChangeSelection(Node? node) {
    // Use identical() instead of == to detect actual instance changes,
    // not just value equality. After NodeContainer.update() creates a
    // clone via cloneWithNewLevel, the clone's NodeDetails has the same
    // values (id, level, owner) as the original, so == returns true and
    // _lastNode was never updated — keeping a stale reference forever.
    if (identical(_lastNode?.details, node?.details)) return;
    if (node != null && node is! File) {
      _showNoFileToWatch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
      _onChangeCalledFromSelectionHandler = true;
      return;
    }
    _lastNode = node as File?;
    _onChangeCalledFromSelectionHandler = true;
    if (_lastNode != null) {
      _loadContent();
      if (_showNoFileToWatch) {
        _showNoFileToWatch = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    }
  }

  void _onDocumentChange(Document document) {
    if (_lastNode == null) return;
    if (!_onChangeCalledFromSelectionHandler) {
      final Delta currentDelta = document.toDelta();
      // making this check, we avoid make a update when it does not
      // needed. OnChange also is called when the selection changes
      if (oldVersion != currentDelta) {
        oldVersion = currentDelta;
        final NodeContainer? owner = _lastNode!.owner;
        final File newCopy = _lastNode!.copyWith(
          // Clone details to break shared
          // mutable reference with _lastNode.
          // Without this, NodeContainer.update()
          // may mutate _lastNode.details.owner
          // as a side effect.
          details: _lastNode!.details.copyWith(),
          content: jsonEncode(
            document.toDelta().toJson(),
          ),
        );
        if (owner != null) {
          owner.asContainer.update(
            newCopy,
          );
        }
      }
    }
  }

  bool onWillAcceptWithDetails(DragTargetDetails<Node> details) {
    _isDraggingAboveEditor.value = true;
    return details.data is File;
  }

  void onMove() {
    _isDraggingAboveEditor.value = true;
  }

  void onLeave() {
    _isDraggingAboveEditor.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final double binderWidth =
        (MediaQuery.sizeOf(context).width * 0.30).clamp(240.0, 320.0).toDouble();
    return Scaffold(
      backgroundColor: _kWorkspaceBackground,
      body: ValueListenableBuilder<Node?>(
        valueListenable: widget.controller.selection,
        builder: (BuildContext context, Node? value, Widget? __) {
          if (value == null) {
            _onRemoveCurrentSelection();
          } else {
            _handleOnChangeSelection(value);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: binderWidth,
                child: RepaintBoundary(
                  child: TreeViewDrawer(controller: widget.controller),
                ),
              ),
              Expanded(
                child: _showNoFileToWatch
                    ? _buildEmptyEditorPlaceholder()
                    : _buildEditorPane(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditorPane(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildBreadcrumb(),
        _buildFormatBar(),
        Expanded(
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: _buildPage()),
              Positioned.fill(child: _buildEditorDropTarget(context)),
            ],
          ),
        ),
      ],
    );
  }

  /// Document path shown above the editor, e.g. `Research ▸ README`.
  List<String> _breadcrumbSegments() {
    final List<String> segments = <String>[];
    Node? current = _lastNode;
    while (current != null && !current.isRoot) {
      if (current.isFile) {
        segments.insert(0, current.asFile.name);
      } else if (current.isDirectory) {
        segments.insert(0, current.asDirectory.name);
      }
      current = current.owner;
    }
    return segments;
  }

  Widget _buildBreadcrumb() {
    final List<String> segments = _breadcrumbSegments();
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kPaneDivider)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < segments.length; i++) ...<Widget>[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            Text(
              segments[i],
              style: TextStyle(
                fontSize: 13,
                color: i == segments.length - 1
                    ? Colors.black87
                    : Colors.grey.shade600,
                fontWeight: i == segments.length - 1
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormatBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kPaneDivider)),
      ),
      child: QuillSimpleToolbar(
        controller: _controller,
        config: const QuillSimpleToolbarConfig(
          multiRowsDisplay: false,
        ),
      ),
    );
  }

  /// White "sheet of paper" centered over the gray workspace.
  Widget _buildPage() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: Container(
          margin: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: MyEditor(
            controller: _controller,
            scrollController: _scrollController,
            configurations: const QuillEditorConfig(
              placeholder: 'Write something',
              scrollable: true,
              expands: true,
              padding: EdgeInsets.symmetric(horizontal: 56, vertical: 40),
            ),
            focusNode: _focusNode,
            onChange: _onDocumentChange,
          ),
        ),
      ),
    );
  }

  /// Invisible while idle; shows a veil + `Open "<file>"` card while a
  /// node from the binder is dragged over the editor. Dropping a [File]
  /// selects (opens) it.
  Widget _buildEditorDropTarget(BuildContext context) {
    return DragTarget<Node>(
      onMove: (_) => onMove(),
      onLeave: (_) => onLeave(),
      onWillAcceptWithDetails: onWillAcceptWithDetails,
      onAcceptWithDetails: (DragTargetDetails<Node> details) {
        _isDraggingAboveEditor.value = false;
        widget.controller.selectNode(details.data);
      },
      builder: (
        BuildContext context,
        List<Node?> candidateData,
        List<dynamic> rejectedData,
      ) {
        final Node? candidate =
            candidateData.isEmpty ? null : candidateData.first;
        return ValueListenableBuilder<bool>(
          valueListenable: _isDraggingAboveEditor,
          builder: (BuildContext context, bool isDragging, Widget? _) {
            if (!isDragging) return const SizedBox.expand();
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          CupertinoIcons.doc_text_fill,
                          size: 20,
                          color: accent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          candidate != null && candidate.isFile
                              ? 'Open "${candidate.asFile.name}"'
                              : 'Drop here to open',
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
          },
        );
      },
    );
  }

  Widget _buildEmptyEditorPlaceholder() {
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
        ],
      ),
    );
  }
}
