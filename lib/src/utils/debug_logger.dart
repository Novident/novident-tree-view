import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Writes structured debug logs to a temp file for post-mortem analysis.
///
/// Log file is stored at:
///   `$TMPDIR/novident_tree_debug_<pid>.log`
///
/// On web (where `dart:io` is unavailable), logging is silently disabled.
///
/// Usage:
/// ```dart
/// NodeDebugLogger.log('update', {
///   'phase': 'before',
///   'nodeId': node.id,
///   'identityHash': identityHashCode(node),
/// });
/// ```
abstract final class NodeDebugLogger {
  static File? _file;
  static final String _pid = pid.toString();

  static File get _logFile {
    if (kIsWeb) {
      throw UnsupportedError('NodeDebugLogger is not available on web.');
    }
    if (_file != null) return _file!;
    final String dir = Platform.environment['TMPDIR'] ??
        Platform.environment['TEMP'] ??
        Directory.systemTemp.path;
    _file = File('$dir/novident_tree_debug_$_pid-new.log');
    // Truncate on first open.
    _file!.writeAsStringSync(
      '=== NOVIDENT TREE DEBUG LOG (pid: $_pid) ===\n'
      '=== Started: ${DateTime.now().toIso8601String()} ===\n\n',
    );
    return _file!;
  }

  /// Writes a timestamped log entry.
  ///
  /// [category] groups related entries (e.g. 'update', 'drag', 'build').
  /// [data] is a map serialized to JSON for the log line.
  static void log(String category, Map<String, Object?> data) {
    if (kIsWeb) return; // Silently disabled on web.
    final String timestamp = DateTime.now().toIso8601String();
    final Map<String, Object?> entry = <String, Object?>{
      'ts': timestamp,
      'cat': category,
      ...data,
    };
    final String line = '${jsonEncode(entry)}\n';
    try {
      _logFile.writeAsStringSync(line, mode: FileMode.append);
    } catch (_) {
      // Fail silently — logging must never crash the app.
    }
  }

  /// Logs identity and state of a [node].
  static Map<String, Object?> nodeSnapshot(
    dynamic node, {
    String label = 'node',
  }) {
    if (node == null) {
      return <String, Object?>{'${label}_null': true};
    }
    return <String, Object?>{
      '${label}_hash': identityHashCode(node),
      '${label}_runtimeType': node.runtimeType.toString(),
      '${label}_id': (node as dynamic).id as String?,
      '${label}_level': (node as dynamic).level as int?,
      '${label}_ownerHash':
          identityHashCode((node as dynamic).owner as Object?),
      '${label}_detailsHash':
          identityHashCode((node as dynamic).details),
      '${label}_details_ownerHash':
          identityHashCode((node as dynamic).details?.owner as Object?),
      '${label}_index': _safeIndex(node),
      '${label}_isDraggable': _safeIsDraggable(node),
      '${label}_isDropTarget': _safeIsDropTarget(node),
    };
  }

  static int? _safeIndex(dynamic node) {
    try {
      return (node as dynamic).index as int?;
    } catch (_) {
      return null;
    }
  }

  static bool? _safeIsDraggable(dynamic node) {
    try {
      return (node as dynamic).isDraggable() as bool?;
    } catch (_) {
      return null;
    }
  }

  static bool? _safeIsDropTarget(dynamic node) {
    try {
      return (node as dynamic).isDropTarget() as bool?;
    } catch (_) {
      return null;
    }
  }

  /// Returns the path to the log file for display to the user.
  static String get filePath {
    if (kIsWeb) return '(not available on web)';
    return _logFile.path;
  }
}
