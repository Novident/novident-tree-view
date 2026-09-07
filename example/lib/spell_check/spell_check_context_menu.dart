import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';

/// A misspelled word found under a pointer position.
typedef MisspelledWord = ({
  Node node,
  String word,
  int start,
  int end,
});

/// Resolves the word under the current collapsed selection and returns it
/// when it is marked as misspelled (`proofState` in the node's delta).
///
/// The desktop selection service leaves the selection collapsed at the
/// exact click point before showing the context menu, so the selection is
/// the reliable source of the click position (the position passed to the
/// menu builder is offset on purpose for comfortable menu placement).
///
/// Returns null when the selection is not collapsed (a real selection is
/// active — the standard menu applies), the node has no text, or the word
/// under the caret is not marked.
MisspelledWord? findMisspelledWord({
  required EditorState editorState,
}) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return null;
  }
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return null;
  }
  final selectable = node.selectable;
  if (selectable == null) {
    return null;
  }
  final boundary = selectable.getWordBoundaryInPosition(selection.start);
  if (boundary == null) {
    return null;
  }
  final start = boundary.start.offset;
  final end = boundary.end.offset;
  if (start >= end) {
    return null;
  }
  final delta = node.delta;
  if (delta == null) {
    return null;
  }
  final slice = delta.slice(start, end);
  final marked = slice.whereType<TextInsert>().any((insert) =>
      insert.attributes?[RichTextKeys.proofState] == proofStateError);
  if (!marked) {
    return null;
  }
  return (node: node, word: slice.toPlainText(), start: start, end: end);
}

/// Builds the context menu for a secondary click.
///
/// When the click lands exactly on a misspelled word it shows the checker's
/// suggestions, an "Add to dictionary" entry, and then [extraItems]
/// (standard cut/copy/paste by default). Otherwise it falls back to
/// [extraItems] alone.
///
/// Suggestions are resolved through [NovidentSpellChecker.suggestAsync], so
/// heavy engines (e.g. a worker isolate) never block the frame: the menu
/// opens immediately and fills the suggestion section when the future
/// completes.
Widget buildSpellCheckContextMenu({
  required BuildContext context,
  required Offset position,
  required EditorState editorState,
  required VoidCallback onPressed,
  required NovidentSpellChecker checker,
  List<ContextMenuItem> extraItems = const [],
}) {
  return _SpellCheckContextMenu(
    position: position,
    editorState: editorState,
    onPressed: onPressed,
    checker: checker,
    extraItems: extraItems,
  );
}

class _SpellCheckContextMenu extends StatefulWidget {
  const _SpellCheckContextMenu({
    required this.position,
    required this.editorState,
    required this.onPressed,
    required this.checker,
    required this.extraItems,
  });

  final Offset position;
  final EditorState editorState;
  final VoidCallback onPressed;
  final NovidentSpellChecker checker;
  final List<ContextMenuItem> extraItems;

  @override
  State<_SpellCheckContextMenu> createState() => _SpellCheckContextMenuState();
}

class _SpellCheckContextMenuState extends State<_SpellCheckContextMenu> {
  late final MisspelledWord? _misspelled;

  /// null = the async suggestion lookup has not completed yet.
  List<String>? _suggestions;

  @override
  void initState() {
    super.initState();
    _misspelled = findMisspelledWord(editorState: widget.editorState);
    final misspelled = _misspelled;
    if (misspelled != null) {
      widget.checker.suggestAsync(misspelled.word).then((suggestions) {
        if (mounted) {
          setState(() => _suggestions = suggestions);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardItems = widget.extraItems.isEmpty
        ? standardContextMenuItems.first
        : widget.extraItems;

    final misspelled = _misspelled;
    if (misspelled == null) {
      return ContextMenu(
        position: widget.position,
        editorState: widget.editorState,
        items: [standardItems],
        onPressed: widget.onPressed,
      );
    }

    final items = <List<ContextMenuItem>>[
      if (standardItems.isNotEmpty) standardItems,
      _buildCorrectionSection(misspelled),
    ];

    return ContextMenu(
      position: widget.position,
      editorState: widget.editorState,
      items: items,
      onPressed: widget.onPressed,
    );
  }

  List<ContextMenuItem> _buildCorrectionSection(MisspelledWord misspelled) {
    final suggestions = _suggestions;
    if (suggestions == null) {
      return [
        // The lookup is running on the checker's side; "Add to dictionary"
        // is available right away, the suggestions fill in when ready.
        ContextMenuItem(
          getName: () => 'Loading suggestions…',
          onPressed: (_) {},
        ),
      ];
    }

    return [
      for (final suggestion in suggestions)
        ContextMenuItem(
          getName: () => suggestion,
          onPressed: (editorState) {
            editorState.apply(
              editorState.transaction
                ..replaceText(
                  misspelled.node,
                  misspelled.start,
                  misspelled.end - misspelled.start,
                  suggestion,
                ),
            );
          },
        ),
      if (suggestions.isEmpty)
        ContextMenuItem(
          getName: () => 'No suggestions',
          onPressed: (_) {},
        ),
      _addToDictionaryItem(misspelled),
    ];
  }

  ContextMenuItem _addToDictionaryItem(MisspelledWord misspelled) {
    return ContextMenuItem(
      getName: () => 'Add to dictionary',
      onPressed: (editorState) {
        widget.checker.addWord(misspelled.word);
        // The word is now valid: re-analyze the node to clear its mark.
        editorState.spellCheckService?.requestAnalysis(misspelled.node);
      },
    );
  }
}
