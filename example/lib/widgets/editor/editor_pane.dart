import 'package:example/common/nodes/file.dart';
import 'package:example/common/store/document_content_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';
import 'package:novident_split_view/novident_split_view.dart';

import 'my_editor.dart';
import 'editor_configuration.dart';
import 'session_controller.dart';
import 'vim_mode_chip.dart';
import 'word_count_chip.dart';

/// A self-contained editor pane for the split view.
///
/// Every pane owns an [EditorSessionController] (editor, scroll, focus
/// and vim state), but the document content lives in the
/// [DocumentContentProvider] (keyed by node id): edits are written there,
/// the provider notifies, and every pane showing the same document re-reads
/// it — duplicated panes stay in sync for free, with no extra wiring.
///
/// Zen mode is toggled **in place** (the status-bar moon button): the same
/// editor dims the unfocused blocks and centers the caret, keeping the
/// pane's look and feel — no separate view.
class EditorPane extends StatefulWidget {
  final File file;
  final bool isFocused;
  final FocusedEditorNotifier toolbarNotifier;
  final NovidentStylesConfig? styles;

  const EditorPane({
    required this.file,
    required this.isFocused,
    required this.toolbarNotifier,
    this.styles,
    super.key,
  });

  @override
  State<EditorPane> createState() => _EditorPaneState();
}

class _EditorPaneState extends State<EditorPane> {
  late EditorSessionController _sessionController;

  /// Zen mode controller shared across document changes (survives
  /// `replace()`); toggled from the status-bar moon button.
  late final ZenModeController _zenController;

  @override
  void initState() {
    super.initState();
    _zenController = ZenModeController(
      configuration: const ZenModeConfiguration(
        enabled: false,
        unfocusedOpacity: 0.3,
      ),
    );
    _sessionController = EditorSessionController(
      nodeId: widget.file.id,
      toolbarNotifier: widget.toolbarNotifier,
      zenController: _zenController,
      typewriterStrategy: const TypewriterScrollStrategy(),
    )
      ..addListener(_onSessionChanged)
      ..isFocused = widget.isFocused;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionController.syncFromStore(DocumentContentProvider.of(context));
  }

  @override
  void didUpdateWidget(covariant EditorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.id != widget.file.id) {
      _sessionController.replace(widget.file.id);
    }
    if (oldWidget.isFocused != widget.isFocused) {
      _sessionController.isFocused = widget.isFocused;
    }
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    _sessionController.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  /// Leading icon of the library's [PaneHeader]: the title, the close
  /// button and the focused tint come for free (SplitViewScope).
  Widget _buildLeadingIcon() {
    return Icon(
      CupertinoIcons.doc_text_fill,
      size: 14,
      color: widget.isFocused ? kEditorAccent : Colors.grey.shade600,
    );
  }

  /// Slim status bar at the bottom of the sheet: vim mode on the left,
  /// the (active) zen toggle on the right.
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 30,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        children: <Widget>[
          VimModeChip(controller: _sessionController.session.vimController),
          const Spacer(),
          WordCountChip(service: _sessionController.session.wordCounter),
          const SizedBox(width: 10),
          ValueListenableBuilder<ZenModeConfiguration>(
            valueListenable: _zenController,
            builder: (BuildContext context, ZenModeConfiguration config, _) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 26, height: 26),
                iconSize: 15,
                tooltip: config.enabled ? 'Exit zen mode' : 'Zen mode',
                icon: Icon(
                  config.enabled
                      ? CupertinoIcons.moon_stars_fill
                      : CupertinoIcons.moon_stars,
                  color: config.enabled ? kEditorAccent : Colors.grey.shade600,
                ),
                onPressed: _zenController.toggle,
              );
            },
          ),
        ],
      ),
    );
  }

  /// White "sheet of paper" centered over the gray workspace.
  Widget _buildPage() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
          child: !_sessionController.isReady
              ? const SizedBox.expand()
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: MyEditor(
                          session: _sessionController.session,
                          styles: widget.styles,
                          zenController:
                              _sessionController.session.zenController,
                          typewriterStrategy:
                              _sessionController.typewriterStrategy,
                        ),
                      ),
                    ),
                    _buildStatusBar(),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaneHeader(
      // Drag the header to move this pane anywhere (center = swap).
      draggable: true,
      leading: _buildLeadingIcon(),
      title: Text(widget.file.name),
      child: _buildPage(),
    );
  }
}
