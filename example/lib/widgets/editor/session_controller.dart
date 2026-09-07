import 'package:example/common/store/document_content_store.dart';
import 'package:flutter/widgets.dart';
import 'package:novident_editor/novident_editor.dart';

import 'document_session.dart';

/// Owns the editing session of one document and publishes its
/// [EditorState] to a shared [FocusedEditorNotifier] while focused.
///
/// This is the single place where the session lifecycle is managed for
/// every editor surface of the app:
///
/// * the desktop split panes (`EditorPane`) each own one controller and
///   share the workspace-level toolbar notifier;
/// * the mobile view owns one controller for the selected document and
///   its own notifier, so both platforms wire the toolbar exactly the
///   same way — only the toolbar placement differs (top on desktop,
///   above the soft keyboard on mobile).
class EditorSessionController extends ChangeNotifier {
  EditorSessionController({
    required String nodeId,
    required this.toolbarNotifier,
    VimModeConfiguration vimConfiguration = const VimModeConfiguration(),
    ZenModeController? zenController,
    TypewriterScrollStrategy? typewriterStrategy,
  })  : _vimConfiguration = vimConfiguration,
        _zenController = zenController,
        _typewriterStrategy = typewriterStrategy,
        _session = DocumentSession(
          nodeId: nodeId,
          vimConfiguration: vimConfiguration,
          zenController: zenController,
          typewriterStrategy: typewriterStrategy,
          ownsZenController: false,
        ) {
    _session.addListener(_onSessionChanged);
    _zenController?.addListener(_onSessionChanged);
  }

  /// Shared across panes (desktop) or owned by the view (mobile).
  final FocusedEditorNotifier toolbarNotifier;

  final VimModeConfiguration _vimConfiguration;

  /// Only supported at construction: [replace] reuses the same
  /// [ZenModeController] across sessions (the controller owns it and
  /// disposes it in [dispose], not per-session).
  final ZenModeController? _zenController;

  final TypewriterScrollStrategy? _typewriterStrategy;

  DocumentSession _session;
  DocumentContentStore? _store;
  bool _isFocused = false;
  bool _disposed = false;

  DocumentSession get session => _session;
  String get nodeId => _session.nodeId;
  bool get isReady => _session.isReady;

  /// The typewriter scroll strategy shared across sessions (if any).
  TypewriterScrollStrategy? get typewriterStrategy => _typewriterStrategy;

  /// While focused, publishes the session [EditorState] so the toolbar
  /// follows this surface; while unfocused, clears the notifier only if
  /// it still points at this session (another pane may have taken over).
  set isFocused(bool value) {
    if (_isFocused == value) {
      return;
    }
    _isFocused = value;
    _scheduleToolbarSync();
  }

  /// Keeps the session in sync with the shared [DocumentContentStore]:
  /// external changes reload the editor, local saves are ignored.
  void syncFromStore(DocumentContentStore store) {
    _store = store;
    _session.syncFromStore(store);
  }

  /// Swaps the session for another document (single-editor mode).
  ///
  /// Same id is a no-op (buffers are never closed by selection changes)
  /// except for re-syncing with the store. The vim configuration is
  /// preserved across swaps.
  void replace(String nodeId) {
    if (nodeId == _session.nodeId) {
      final DocumentContentStore? store = _store;
      if (store != null) {
        _session.syncFromStore(store);
      }
      return;
    }
    final DocumentSession oldSession = _session;
    if (oldSession.isReady && toolbarNotifier.value == oldSession.editorState) {
      toolbarNotifier.value = null;
    }
    oldSession.dispose();
    _session = DocumentSession(
      nodeId: nodeId,
      vimConfiguration: _vimConfiguration,
      zenController: _zenController,
      typewriterStrategy: _typewriterStrategy,
      ownsZenController: false,
    )..addListener(_onSessionChanged);
    final DocumentContentStore? store = _store;
    if (store != null) {
      _session.syncFromStore(store);
    }
    notifyListeners();
    _scheduleToolbarSync();
  }

  void _onSessionChanged() {
    if (_disposed) {
      return;
    }
    _scheduleToolbarSync();
    notifyListeners();
  }

  void _scheduleToolbarSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) {
        return;
      }
      final DocumentSession session = _session;
      if (_isFocused && session.isReady) {
        toolbarNotifier.value = session.editorState;
      } else if (!_isFocused &&
          session.isReady &&
          toolbarNotifier.value == session.editorState) {
        toolbarNotifier.value = null;
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    final DocumentSession session = _session;
    if (session.isReady && toolbarNotifier.value == session.editorState) {
      // Synchronous on purpose: a post-frame callback would run after the
      // owning view (and its toolbar notifier) has been disposed, touching
      // a dead notifier. The pane disposes before its ancestor view, so
      // the notifier is still alive here.
      if (toolbarNotifier.hasListeners && !_disposed) {
        toolbarNotifier.value = null;
      }
    }
    session.dispose();
    _zenController?.dispose();
    super.dispose();
  }
}
