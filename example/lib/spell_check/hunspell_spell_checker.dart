import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:novident_editor/novident_editor.dart';
import 'package:novident_spell_checker/novident_spell_checker.dart';

import 'spell_check_worker.dart';

/// Demo [NovidentSpellChecker] backed by the standalone `novident_spell_checker`
/// library and the bundled Hunspell `en_US` dictionary (`.dic` + `.aff`).
///
/// Loaded once at startup with [load]:
/// - validity: compact [Trie] over the expanded dictionary (O(1) per word,
///   used by the idle analysis hot path, synchronous on the UI isolate);
/// - suggestions: a long-lived worker isolate (see `spell_check_worker.dart`)
///   that owns the heavy [SymSpellEx] index — parsing, affix expansion and
///   training all happen off the UI isolate, and [suggestAsync] answers
///   through ports. Use [suggestAsync] on the caller side ([suggest] stays
///   for contract compatibility and only reads the local cache).
///
/// Note: worker isolates do not survive hot reload (the checker must be
/// reloaded through [load]); accepted trade-off for keeping the UI isolate
/// free of dictionary work.
class HunspellSpellChecker implements NovidentSpellChecker {
  HunspellSpellChecker._({
    required this.vocabulary,
    required SendPort workerPort,
    required Isolate workerIsolate,
    required ReceivePort receivePort,
    required Map<int, Completer<List<String>>> pending,
  })  : _workerPort = workerPort,
        _workerIsolate = workerIsolate,
        _receivePort = receivePort,
        _pending = pending;

  static HunspellSpellChecker? _instance;

  /// The loaded instance. Call [load] before accessing it.
  static HunspellSpellChecker get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('HunspellSpellChecker.load() has not been called.');
    }
    return instance;
  }

  final Trie vocabulary;
  final SendPort _workerPort;
  final Isolate _workerIsolate;
  final ReceivePort _receivePort;
  final CoreTokenizer _tokenizer = CoreTokenizer();

  /// Runtime personal dictionary: learned words and forgotten words.
  final Set<String> _learned = {};
  final Set<String> _forgotten = {};

  /// LRU-ish cache for suggestions: the context menu suggests the same word
  /// on repeated right-clicks, and each worker round-trip has a cost.
  final Map<String, List<String>> _suggestCache = {};
  static const int _suggestCacheCapacity = 64;

  int _nextRequestId = 0;
  final Map<int, Completer<List<String>>> _pending;

  bool _disposed = false;

  /// Loads the bundled en_US assets and spawns the suggestion worker.
  static Future<HunspellSpellChecker> load() async {
    final existing = _instance;
    if (existing != null) {
      return existing;
    }
    final dictionary = await rootBundle.load('assets/dictionaries/en_US.dic');
    final affix = await rootBundle.load('assets/dictionaries/en_US.aff');
    return loadFromBytes(
      dictionary.buffer.asUint8List(
        dictionary.offsetInBytes,
        dictionary.lengthInBytes,
      ),
      affix.buffer.asUint8List(affix.offsetInBytes, affix.lengthInBytes),
    );
  }

  /// Builds a checker from raw Hunspell bytes, spawning the worker isolate.
  ///
  /// Public so tests can inject a small dictionary.
  static Future<HunspellSpellChecker> loadFromBytes(
    Uint8List dictionaryBytes,
    Uint8List affixBytes,
  ) async {
    final existing = _instance;
    if (existing != null) {
      return existing;
    }
    final receivePort = ReceivePort();
    final readyCompleter = Completer<SpellCheckWorkerReady>();
    final pending = <int, Completer<List<String>>>{};

    receivePort.listen((message) {
      if (message is SpellCheckWorkerReady) {
        readyCompleter.complete(message);
      } else if (message is SpellCheckSuggestResponse) {
        pending.remove(message.id)?.complete(message.suggestions);
      }
    });

    final isolate = await Isolate.spawn(
      spellCheckWorkerEntry,
      SpellCheckWorkerConfig(
        clientPort: receivePort.sendPort,
        dictionaryBytes: dictionaryBytes,
        affixBytes: affixBytes,
        language: Languages.english,
      ),
    );

    final ready = await readyCompleter.future;
    final checker = HunspellSpellChecker._(
      vocabulary: Trie.fromLines(ready.terms),
      workerPort: ready.workerPort,
      workerIsolate: isolate,
      receivePort: receivePort,
      pending: pending,
    );
    _instance = checker;
    return checker;
  }

  @override
  String? get language => Languages.english;

  @override
  bool isValid(String word) {
    final normalized = word.toLowerCase();
    if (_forgotten.contains(normalized)) {
      return false;
    }
    return _learned.contains(normalized) || vocabulary.contains(normalized);
  }

  @override
  void addWord(String word) {
    final normalized = word.toLowerCase().trim();
    _forgotten.remove(normalized);
    if (_learned.add(normalized)) {
      vocabulary.insert(normalized);
      _workerPort.send(SpellCheckAddWordRequest(normalized));
      _suggestCache.clear();
    }
  }

  @override
  void forgetWord(String word) {
    final normalized = word.toLowerCase().trim();
    _learned.remove(normalized);
    _forgotten.add(normalized);
    _suggestCache.clear();
  }

  @override
  List<SpellCheckIssue> check(String text) {
    final issues = <SpellCheckIssue>[];
    for (final token in _tokenizer.tokenize(text)) {
      // novident_spell_checker >= 1.0.1: Token.offset is the exact start
      // offset in the original input; the issue must cover ONLY the word
      // (spacing stays outside the mark).
      if (token.tag == TokenTags.word &&
          token.value.length >= 2 &&
          !isValid(token.value)) {
        issues.add(SpellCheckIssue(
          startOffset: token.offset,
          endOffset: token.offset + token.value.length,
          word: token.value,
        ));
      }
    }
    return issues;
  }

  /// Synchronous contract entry point: serves cached suggestions only.
  ///
  /// On a miss it warms the cache in the background and returns empty —
  /// callers that render suggestions must use [suggestAsync].
  @override
  List<String> suggest(String word) {
    final cached = _suggestCache[word];
    if (cached != null) {
      return cached;
    }
    unawaited(suggestAsync(word));
    return const [];
  }

  /// Asynchronous suggestions answered by the worker isolate.
  @override
  Future<List<String>> suggestAsync(String word) {
    final cached = _suggestCache.remove(word);
    if (cached != null) {
      _suggestCache[word] = cached;
      return Future.value(cached);
    }

    if (_disposed) {
      return Future.value(const <String>[]);
    }

    final id = _nextRequestId++;
    final completer = Completer<List<String>>();
    _pending[id] = completer;
    _workerPort.send(SpellCheckSuggestRequest(id, word));

    return completer.future.then((suggestions) {
      _suggestCache[word] = suggestions;
      if (_suggestCache.length > _suggestCacheCapacity) {
        for (final key in _suggestCache.keys.take(8)) {
          _suggestCache.remove(key);
        }
      }
      return suggestions;
    });
  }

  /// Remembers a suggestion list. Public so the demo app and its tests can
  /// inspect the cache.
  List<String>? cachedSuggestions(String word) => _suggestCache[word];

  /// Kills the worker isolate and drops pending requests.
  void dispose() {
    _disposed = true;
    _receivePort.close();
    _workerIsolate.kill(priority: Isolate.immediate);
    for (final completer in _pending.values) {
      completer.complete(const <String>[]);
    }
    _pending.clear();
    if (identical(_instance, this)) {
      _instance = null;
    }
  }
}
