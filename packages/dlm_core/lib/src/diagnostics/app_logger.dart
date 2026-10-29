import 'dart:collection';
import 'dart:io';

import 'redactor.dart';

/// Severity of a log line.
enum LogLevel {
  /// Detail for developers.
  debug,

  /// Normal events.
  info,

  /// Something unexpected that the app handled.
  warning,

  /// Something failed.
  error,
}

/// The app's log: a rotating file in the log directory and the last lines in
/// memory (for the diagnostics bundle). Everything is redacted on the way in.
///
/// Nothing leaves the machine: there is no network sink and no telemetry.
class AppLogger {
  /// Creates a logger writing to [directory].
  AppLogger({
    required this.directory,
    required this.redactor,
    this.fileName = 'dlm-app.log',
    this.maxFileBytes = 1024 * 1024,
    this.maxFiles = 5,
    this.memoryLines = 500,
    this.level = LogLevel.info,
    DateTime Function() now = DateTime.now,
  }) : _now = now;

  /// Where the files are.
  final Directory directory;

  /// Removes secrets from every line.
  final Redactor redactor;

  /// Base name of the log file (`dlm-app.log`, `dlm-app.log.1`, ...).
  final String fileName;

  /// A file is rotated once it exceeds this size.
  final int maxFileBytes;

  /// How many files are kept (the current one included).
  final int maxFiles;

  /// How many recent lines [recent] keeps.
  final int memoryLines;

  /// Lines below this level are dropped.
  LogLevel level;

  final DateTime Function() _now;
  final _recent = Queue<String>();

  File get _file => File('${directory.path}${Platform.pathSeparator}$fileName');

  /// The last lines, oldest first.
  List<String> get recent => List.unmodifiable(_recent);

  /// Writes one line.
  void log(LogLevel at, String message, {Object? error, StackTrace? stack}) {
    if (at.index < level.index) return;
    final buffer = StringBuffer()
      ..write(_now().toUtc().toIso8601String())
      ..write(' ')
      ..write(at.name.toUpperCase().padRight(7))
      ..write(' ')
      ..write(message);
    if (error != null) buffer.write(' | $error');
    if (stack != null) buffer.write('\n$stack');
    final line = redactor.redact(buffer.toString());
    _recent.addLast(line);
    while (_recent.length > memoryLines) {
      _recent.removeFirst();
    }
    _append(line);
  }

  /// Debug line.
  void debug(String message) => log(LogLevel.debug, message);

  /// Info line.
  void info(String message) => log(LogLevel.info, message);

  /// Warning line.
  void warning(String message, {Object? error}) =>
      log(LogLevel.warning, message, error: error);

  /// Error line.
  void error(String message, {Object? error, StackTrace? stack}) =>
      log(LogLevel.error, message, error: error, stack: stack);

  void _append(String line) {
    try {
      directory.createSync(recursive: true);
      final file = _file;
      if (file.existsSync() && file.lengthSync() > maxFileBytes) _rotate();
      file.writeAsStringSync('$line\n', mode: FileMode.append);
    } on FileSystemException {
      // Logging must never take the app down; the memory copy remains.
    }
  }

  void _rotate() {
    final last = File('${_file.path}.${maxFiles - 1}');
    if (last.existsSync()) last.deleteSync();
    for (var i = maxFiles - 2; i >= 1; i--) {
      final f = File('${_file.path}.$i');
      if (f.existsSync()) f.renameSync('${_file.path}.${i + 1}');
    }
    _file.renameSync('${_file.path}.1');
  }

  /// The log files, newest first.
  List<File> files() => [
    for (final f in [
      _file,
      for (var i = 1; i < maxFiles; i++) File('${_file.path}.$i'),
    ])
      if (f.existsSync()) f,
  ];
}
