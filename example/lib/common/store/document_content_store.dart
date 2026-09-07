import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:novident_editor/novident_editor.dart' show Document;

/// Single source of truth for every document's content, keyed by
/// node id.
///
/// The [File] nodes carry NO content anymore: every pane (and any
/// other reader) resolves it from this map, so all the panes sharing
/// the same node id stay updated for free — an edit writes here via
/// [setContent], the store notifies, and every dependent widget
/// re-reads the fresh content.
class DocumentContentStore extends ChangeNotifier {
  DocumentContentStore({Map<String, String>? initialContents})
      : _contents = <String, String>{...?initialContents};

  final Map<String, String> _contents;

  /// The JSON of an empty Novident Editor document.
  static final String emptyDocument = jsonEncode(
    Document.blank(withInitialText: true).toJson(),
  );

  /// The content of [nodeId], or an empty document when absent.
  String contentOf(String nodeId) => _contents[nodeId] ?? emptyDocument;

  /// Whether [nodeId] has real (non-empty) content.
  bool hasContent(String nodeId) {
    final String? content = _contents[nodeId];
    return content != null && content.isNotEmpty && content != emptyDocument;
  }

  /// Stores [content] as the document of [nodeId] and notifies every
  /// dependent (all the panes showing that node included).
  void setContent(String nodeId, String content) {
    if (_contents[nodeId] == content) return;
    _contents[nodeId] = content;
    notifyListeners();
  }

  /// Removes the content of [nodeId] (e.g. the document was deleted).
  void remove(String nodeId) {
    if (_contents.remove(nodeId) != null) {
      notifyListeners();
    }
  }
}

/// Exposes the [DocumentContentStore] to the widget tree.
///
/// Mounted above the `MaterialApp` (same pattern as
/// `SplitViewProvider`): dependents rebuild automatically on every
/// content change.
class DocumentContentProvider extends InheritedNotifier<DocumentContentStore> {
  const DocumentContentProvider({
    required DocumentContentStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  /// Retrieves the nearest store, registering a build dependency.
  static DocumentContentStore of(BuildContext context) {
    final DocumentContentStore? store = maybeOf(context);
    if (store == null) {
      throw FlutterError(
        'DocumentContentProvider not found in the widget tree.\n'
        'Wrap your app with a DocumentContentProvider above the '
        'MaterialApp.',
      );
    }
    return store;
  }

  /// Nullable version of [of].
  static DocumentContentStore? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DocumentContentProvider>()
      ?.notifier;
}
