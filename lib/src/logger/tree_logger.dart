import '../entities/enums/log_level.dart';
import '../entities/enums/log_state.dart';
import '../interfaces/base_logger.dart';

const String _stacktraceHead =
    '---------------------#Stacktrace#---------------------------';

class TreeLogger extends BaseLogger {
  // this buffer is just for testing by now
  final StringBuffer _buffer = StringBuffer();

  TreeLogger({
    required super.state,
  });

  @override
  void writeLog(
      {required LogLevel level,
      required String message,
      Object? data,
      StackTrace? stackTrace}) {
    if (state == LogState.debug) {
      final String head = level == LogLevel.error
          ? '----------------------${DateTime.now()}---------------------\n'
          : '';
      final String stacktraceMessage = level != LogLevel.error
          ? ''
          : stackTrace == null
              ? 'No has any Stack\n'
              : '$stackTrace\n';
      final String levelMessage = 'Level: ${level.name}\n';
      final String logmessage = 'Message: $message\n';
      final String object = 'Object: $data\n';
      _buffer.writeln(
          '$head$levelMessage$logmessage$object$_stacktraceHead$_stacktraceHead$stacktraceMessage');
    }
    if (state == LogState.production) {
      _buffer.writeln(message);
    }
    logsController.add('$_buffer');
  }
}
