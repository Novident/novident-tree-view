import 'dart:async';
import 'package:flutter/foundation.dart';
import '../entities/enums/log_level.dart';
import '../entities/enums/log_state.dart';

/// Represents the base class
/// for a logger that write the actions into the 
/// tree
abstract class BaseLogger {
  /// Decide which is the state of the logger
  /// since we can write logs by a different way
  /// when our apps are in debug or production mode
  final LogState state;

  @protected
  bool disposed = false;

  BaseLogger({
    required this.state,
  });

  @protected
  final StreamController<String> logsController = StreamController.broadcast();

  void writeLog({
    required LogLevel level,
    required String message,
    Object? data,
    StackTrace? stackTrace,
  });

  @mustCallSuper
  void dispose() {
    logsController.close();
    disposed = true;
  }

  @mustCallSuper
  void verifyState() {
    assert(!disposed, 'This Logger is not longer used because it is disposed');
  }

  @mustCallSuper
  Stream<String> get changes {
    verifyState();
    return logsController.stream;
  }
}
