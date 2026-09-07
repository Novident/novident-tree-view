import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:novident_spell_checker/novident_spell_checker.dart';

/// Configuration handed to the worker isolate on spawn.
class SpellCheckWorkerConfig {
  const SpellCheckWorkerConfig({
    required this.clientPort,
    required this.dictionaryBytes,
    required this.affixBytes,
    required this.language,
  });

  /// Port owned by the UI isolate; the worker reports readiness and serves
  /// every response through it.
  final SendPort clientPort;

  /// Raw `.dic` bytes (Hunspell format).
  final Uint8List dictionaryBytes;

  /// Raw `.aff` bytes (companion affix rules; may be empty).
  final Uint8List affixBytes;

  /// Language code used to train and query the suggestion index.
  final String language;
}

/// Ready message: expanded term list (for the UI-side validity [Trie])
/// plus the worker's own request port.
class SpellCheckWorkerReady {
  const SpellCheckWorkerReady({required this.terms, required this.workerPort});

  final List<String> terms;
  final SendPort workerPort;
}

/// A suggestion request sent by the UI isolate.
class SpellCheckSuggestRequest {
  const SpellCheckSuggestRequest(this.id, this.word);

  final int id;
  final String word;
}

/// A suggestion response sent back to the UI isolate.
class SpellCheckSuggestResponse {
  const SpellCheckSuggestResponse(this.id, this.suggestions);

  final int id;
  final List<String> suggestions;
}

/// Asks the worker to learn a word at runtime (personal dictionary).
class SpellCheckAddWordRequest {
  const SpellCheckAddWordRequest(this.word);

  final String word;
}

/// Entry point of the long-lived suggestion worker isolate.
///
/// The heavy work of the demo checker lives entirely here, off the UI
/// isolate:
///
///  1. parses and expands the Hunspell dictionary (stems + affix forms);
///  2. reports the expanded term list back so the UI can build its
///     synchronous validity trie;
///  3. trains the [SymSpellEx] index incrementally from the dictionary's
///     own byte stream (`term,frequency` chunks — the raw line list is
///     never materialized);
///  4. serves suggestion/add-word requests over ports.
///
/// The dictionary bytes are copied into this isolate exactly once at
/// spawn; every request after that is a tiny message.
void spellCheckWorkerEntry(SpellCheckWorkerConfig config) {
  final receivePort = ReceivePort();

  // 1. Parse + expand (heavy).
  final dictionary = HunspellDictionary.fromString(
    utf8.decode(config.dictionaryBytes),
  );
  final affix = AffixRules.fromString(utf8.decode(config.affixBytes));
  final expanded = dictionary.expand(affix);

  // 2. Report readiness right away: the UI can already validate words
  //    (idle analysis hot path) while the suggestion index is trained.
  config.clientPort.send(
    SpellCheckWorkerReady(
      terms: expanded.terms.keys.toList(growable: false),
      workerPort: receivePort.sendPort,
    ),
  );

  // 3. Train the suggestion index from the library's byte stream.
  final suggester = SymSpellEx(MemoryStore())..initialize();
  final Future<void> training = suggester.trainByteStream(
    expanded.toByteStream(),
    config.language,
  );

  // 4. Serve requests sequentially: async handlers on a stream listener
  //    interleave at every await, so an add-word followed by a suggest must
  //    be chained to guarantee the add lands first.
  Future<void> queue = Future<void>.value();
  receivePort.listen((message) {
    queue = queue.then((_) async {
      if (message is SpellCheckSuggestRequest) {
        await training;
        final suggestions = suggester
            .lookup(
              message.word,
              language: config.language,
              maxSuggestions: 7,
            )
            .map((suggestion) => suggestion.suggestion ?? suggestion.term)
            .toList(growable: false);
        config.clientPort.send(
          SpellCheckSuggestResponse(message.id, suggestions),
        );
      } else if (message is SpellCheckAddWordRequest) {
        await training;
        suggester.add(message.word, 1, config.language);
      }
    });
  });
}
