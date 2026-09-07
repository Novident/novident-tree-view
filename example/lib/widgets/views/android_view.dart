import 'dart:async';

import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/nodes/file.dart';
import 'package:example/common/store/document_content_store.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novident_editor/novident_editor.dart';

import '../drawer/tree_view_drawer.dart';
import '../editor/editor_configuration.dart';
import '../editor/my_editor.dart';
import '../editor/session_controller.dart';

/// Mobile workspace: a single editor filling the screen.
///
/// Shares the desktop view's logic — session lifecycle
/// ([EditorSessionController]), tree selection ([TreeController]),
/// editor styles ([kEditorStyles]) and toolbar wiring
/// ([FocusedEditorNotifier]) — the only differences are the missing
/// split view (a phone cannot fit panes) and the toolbar placement:
/// above the soft keyboard instead of the top of the editor.
///
/// Zen mode is toggled **in place** (the AppBar moon button): unlike the
/// desktop, a phone cannot open a separate zen view, so the same editor
/// dims the unfocused blocks and centers the caret while zen is active.
class AndroidTreeViewExample extends StatefulWidget {
  final TreeController controller;
  const AndroidTreeViewExample({
    super.key,
    required this.controller,
  });

  @override
  State<AndroidTreeViewExample> createState() => _AndroidTreeViewExampleState();
}

class _AndroidTreeViewExampleState extends State<AndroidTreeViewExample> {
  late final TreeController treeController;
  final FocusedEditorNotifier _toolbarNotifier = FocusedEditorNotifier();
  EditorSessionController? _sessionController;
  DocumentContentStore? _store;

  /// Zen mode controller shared across document changes (survives
  /// `replace()`); toggled from the AppBar moon button.
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
    treeController = widget.controller
      ..selectNode(widget.controller.root.atPath(<int>[0, 0]));
    treeController.selection.addListener(_onSelectionChanged);
    treeController.root.addListener(_onTreeChanged);
    _initAndroidNativeTextProcessActions();
    final File? initial = treeController.selectedFile;
    if (initial != null) {
      _openSession(initial.id);
    }
  }

  /// Selecting a document in the binder opens it — same semantics as
  /// the desktop view, but a phone has a single editor, so the session
  /// is swapped in place (buffers are never closed by selection
  /// changes; the previous session stays alive for the next visit).
  void _onSelectionChanged() {
    if (!mounted) return;
    final File? file = treeController.selectedFile;
    if (file != null) {
      _openSession(file.id);
    }
    setState(() {});
  }

  /// Tree mutations (renames, deletions from the trash target...) must
  /// refresh the editor: it resolves its [File] by id on each build.
  void _onTreeChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final DocumentContentStore store = DocumentContentProvider.of(context);
    _store = store;
    _sessionController?.syncFromStore(store);
  }

  @override
  void dispose() {
    treeController.selection.removeListener(_onSelectionChanged);
    treeController.root.removeListener(_onTreeChanged);
    treeController
      ..invalidateSelection()
      ..dispose();
    _sessionController?.dispose();
    _toolbarNotifier.dispose();
    super.dispose();
  }

  /// Opens [nodeId] in the single mobile editor.
  ///
  /// Vim emulation is disabled on mobile: its normal mode would
  /// suppress the soft keyboard input (see [kMobileVimConfiguration]).
  void _openSession(String nodeId) {
    final EditorSessionController? current = _sessionController;
    final DocumentContentStore? store = _store;
    if (current == null) {
      _sessionController = EditorSessionController(
        nodeId: nodeId,
        toolbarNotifier: _toolbarNotifier,
        vimConfiguration: kMobileVimConfiguration,
        zenController: _zenController,
        typewriterStrategy: const TypewriterScrollStrategy(),
      )
        ..addListener(_onSessionChanged)
        ..isFocused = true;
      if (store != null) {
        _sessionController!.syncFromStore(store);
      }
    } else {
      current.replace(nodeId);
    }
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  /// The native context menu items (e.g., `Translate`, `Search`).
  /// This is Android-specific and is always `null` on other platforms.
  List<ProcessTextAction>? _nativeTextProcessActions;

  // Always `null` on platforms other than Android.
  @visibleForTesting
  ProcessTextService? processTextService;

  /// The native context menu items like `Translate` and `Search` on Android.
  ///
  /// This feature is platform-specific and will
  /// be silently ignored on platforms other than Android.
  ///
  /// To use this feature, ensure the following is added in your `AndroidManifest.xml`:
  ///
  /// ```xml
  /// <queries>
  ///  <intent>
  ///      <action android:name="android.intent.action.PROCESS_TEXT"/>
  ///      <data android:mimeType="text/plain"/>
  ///  </intent>
  /// </queries>
  /// ```
  Future<void> _initAndroidNativeTextProcessActions() async {
    if (EditorPlatform.isAndroid) {
      processTextService ??= DefaultProcessTextService();
      _nativeTextProcessActions = [
        ...await processTextService!.queryTextActions()
      ];
    }
  }

  // For the original method,
  // refer to:
  // https://github.com/flutter/flutter/blob/9e211cabbd72de59d79decacfe0ad6f707c61366/packages/flutter/lib/src/widgets/editable_text.dart#L3059-L3091
  List<ContextMenuButtonItem> _buildTextProcessingActionButtonItems(
    EditorState state,
  ) {
    final buttonItems = <ContextMenuButtonItem>[];

    if (state.selection == null || state.selection!.isCollapsed) {
      return buttonItems;
    }
    final textEditingValue =
        state.getTextInSelection(state.selection).join('\n');
    if (textEditingValue.isEmpty) return buttonItems;

    for (final action in _nativeTextProcessActions ?? []) {
      buttonItems.add(
        ContextMenuButtonItem(
          label: action.label,
          onPressed: () async {
            final processedText = await processTextService!.processTextAction(
              action.id,
              textEditingValue,
              !state.editable,
            );

            if (processedText == null ||
                textEditingValue == processedText ||
                !state.editable) {
              unawaited(state.updateSelectionWithReason(
                  Selection.collapsed(state.selection!.start)));
              return;
            }

            if (processedText.isNotEmpty) {
              await state.pastePlainText(processedText);
            }
          },
        ),
      );
    }
    return buttonItems;
  }

  Widget _buildEditor() {
    final EditorSessionController? controller = _sessionController;
    if (controller == null || !controller.isReady) {
      return const SizedBox.expand();
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: MobileFloatingToolbar(
            editorState: controller.session.editorState,
            editorScrollController: controller.session.scrollController,
            floatingToolbarHeight: 32,
            toolbarBuilder: (context, anchor, closeToolbar) {
              final editorState = controller.session.editorState;
              final buttons = EditableText.getEditableButtonItems(
                clipboardStatus: editorState.editable
                    ? ClipboardStatus.pasteable
                    : ClipboardStatus.notPasteable,
                onCopy: () {
                  copyCommand.execute(editorState);
                  closeToolbar();
                },
                onCut: () => cutCommand.execute(editorState),
                onPaste: () => pasteCommand.execute(editorState),
                onSelectAll: () => selectAllCommand.execute(editorState),
                onLiveTextInput: null,
                onLookUp: null,
                onSearchWeb: null,
                onShare: null,
              );
              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: [
                  ...buttons,
                  ..._buildTextProcessingActionButtonItems(editorState),
                ],
                anchors: TextSelectionToolbarAnchors(
                  primaryAnchor: anchor,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: MyEditor(
                key: ValueKey(controller.nodeId),
                session: controller.session,
                styles: kEditorStyles,
                padding: EdgeInsets.symmetric(horizontal: 10),
                zenController: controller.session.zenController,
                typewriterStrategy: controller.typewriterStrategy,
              ),
            ),
          ),
        ),
        // The mobile toolbar lives above the soft keyboard; the
        // [MobileToolbar] fills the keyboard inset itself.
        _buildMobileToolbar(),
      ],
    );
  }

  /// Same toolbar wiring as the desktop view: the toolbar follows the
  /// focused editor through the shared [FocusedEditorNotifier]. The
  /// styles are wrapped explicitly because the toolbar lives outside
  /// the editor — the desktop [NovidentStaticToolbar] does this itself.
  Widget _buildMobileToolbar() {
    return ValueListenableBuilder<EditorState?>(
      valueListenable: _toolbarNotifier,
      builder: (BuildContext context, EditorState? editorState, _) {
        final EditorSessionController? controller = _sessionController;
        if (controller == null || !controller.isReady) {
          return const SizedBox.shrink();
        }
        return NovidentEditorStyles(
          config: kEditorStyles,
          child: MobileToolbar(
            editorState: editorState ?? controller.session.editorState,
            toolbarItems: kMobileToolbarItems,
          ),
        );
      },
    );
  }

  /// Shown when the selection is not a [File] — the mobile analog of
  /// the desktop's empty split view target.
  Widget _buildNoFileToWatch() {
    return const Center(
      child: Text(
        'There\'s no File to watch...',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final File? selected = treeController.selectedFile;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(selected?.name ?? 'No name'),
        actions: <Widget>[
          // Zen mode toggles in place (no separate view on a phone): the
          // same editor dims unfocused blocks and centers the caret.
          ValueListenableBuilder<ZenModeConfiguration>(
            valueListenable: _zenController,
            builder: (BuildContext context, ZenModeConfiguration config, _) {
              return IconButton(
                tooltip: config.enabled ? 'Exit zen mode' : 'Enter zen mode',
                icon: Icon(
                  config.enabled
                      ? CupertinoIcons.moon_stars_fill
                      : CupertinoIcons.moon_stars,
                  color: config.enabled ? kEditorAccent : null,
                ),
                onPressed: _zenController.toggle,
              );
            },
          ),
        ],
      ),
      drawer: TreeViewDrawer(
        controller: widget.controller,
      ),
      body: selected == null ? _buildNoFileToWatch() : _buildEditor(),
    );
  }
}
