import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';

/// Compact word/character counter for the editor status bars.
///
/// Shows the document totals; while a selection is active (mouse or vim
/// visual mode) it switches to `selected/total` for both counts.
class WordCountChip extends StatelessWidget {
  const WordCountChip({super.key, required this.service});

  final WordCountService service;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (BuildContext context, _) {
        final Counters document = service.documentCounters;
        final Counters selection = service.selectionCounters;

        final String words = selection.wordCount > 0
            ? '${selection.wordCount}/${document.wordCount}'
            : '${document.wordCount}';
        final String chars = selection.charCount > 0
            ? '${selection.charCount}/${document.charCount}'
            : '${document.charCount}';

        return Text(
          '$words words · $chars chars',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        );
      },
    );
  }
}
