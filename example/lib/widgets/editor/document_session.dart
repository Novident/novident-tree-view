import 'dart:async';
import 'dart:convert';

import 'package:example/common/store/document_content_store.dart';
import 'package:flutter/widgets.dart';
import 'package:novident_editor/novident_editor.dart';

/// Owns the editing state of one document (keyed by node id) and keeps
/// it in sync with the [DocumentContentStore]:
///
/// * external store changes rebuild the [editorState] (and notify);
/// * local transactions are written back to the store;
/// * the vim controller (and optionally a zen controller) are re-attached
///   every time the editor is rebuilt.
///
/// Shared by every editor surface of the app (split view panes, the zen
/// view and the mobile view), so they all read/write the same source of
/// truth.
class DocumentSession extends ChangeNotifier {
  DocumentSession({
    required this.nodeId,
    VimModeConfiguration vimConfiguration = const VimModeConfiguration(),
    this.zenController,
    this.typewriterStrategy,
    this.ownsZenController = true,
  }) : vimController = VimModeController(configuration: vimConfiguration);

  final String nodeId;

  /// Vim emulation of this session (enabled by default).
  final VimModeController vimController;

  /// Optional zen controller (used by the zen view).
  final ZenModeController? zenController;

  /// Optional typewriter scroll strategy (used by the zen view).
  final TypewriterScrollStrategy? typewriterStrategy;

  /// Whether this session owns (and disposes) the [zenController].
  ///
  /// Defaults to `true` (the zen view owns its controller). Surfaces that
  /// share one controller across sessions — e.g. the mobile view, which
  /// swaps documents in place via `replace()` — pass `false` and dispose it
  /// themselves, so the controller survives document changes.
  final bool ownsZenController;

  /// Persistent focus node: survives editor rebuilds.
  final FocusNode focusNode = FocusNode();

  static const Duration saveDelay = Duration(milliseconds: 400);

  EditorState? _editorState;
  EditorScrollController? _scrollController;
  WordCountService? _wordCounter;
  StreamSubscription<EditorTransactionValue>? _subscription;
  DocumentContentStore? _store;
  String _lastContent = '';
  bool _disposed = false;
  Timer? _saveTimer;

  bool get isReady => _editorState != null;

  EditorState get editorState => _editorState!;

  EditorScrollController get scrollController => _scrollController!;

  /// Live word/character counters of the current document.
  WordCountService get wordCounter => _wordCounter!;

  /// Reloads the document from [store] when it really changed.
  ///
  /// Equal content means our own save coming back (or a no-op): never
  /// reload in that case — it would clobber the cursor mid-typing.
  void syncFromStore(DocumentContentStore store) {
    _store = store;
    final String content = store.contentOf(nodeId);
    if (content == _lastContent) {
      return;
    }
    _lastContent = content;
    _rebuildEditor(content);
    notifyListeners();
  }

  void _rebuildEditor(String content) {
    _subscription?.cancel();
    vimController.detach();
    zenController?.detach();
    _wordCounter?.dispose();
    _scrollController?.dispose();
    _editorState?.dispose();

    final EditorState editorState = EditorState(
      document: Document.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      ),
    );
    _editorState = editorState;

    _scrollController = EditorScrollController(editorState: editorState);
    _wordCounter = WordCountService(editorState: editorState)..register();
    _subscription = editorState.transactionStream.listen(
      (EditorTransactionValue value) {
        if (value.$1 == TransactionTime.after) {
          _save();
        }
      },
    );

    // the keyboard service only exists after the editor is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || _editorState != editorState) {
        return;
      }
      vimController.attach(editorState);
      zenController?.attach(
        editorState: editorState,
        scrollController: _scrollController,
      );
    });
  }

  /// Writes real edits into the store: every other surface showing this
  /// document reloads from there automatically.
  ///
  /// Debounced at 2 seconds so rapid typing only triggers one save after
  /// the user pauses. This avoids the 25+ ms hit of jsonEncode on every
  /// keystroke with large documents.
  void _save() {
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, () {
      final EditorState? editorState = _editorState;
      if (editorState == null || _disposed) {
        return;
      }
      final String content = jsonEncode(editorState.document.toJson());
      if (content == _lastContent || _store == null) {
        return;
      }
      _lastContent = content;
      _store!.setContent(nodeId, content);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _saveTimer?.cancel();
    _subscription?.cancel();
    vimController.dispose();
    if (ownsZenController) {
      zenController?.dispose();
    }
    _wordCounter?.dispose();
    _scrollController?.dispose();
    _editorState?.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
