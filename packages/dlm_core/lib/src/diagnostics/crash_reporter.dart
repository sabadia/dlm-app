import 'dart:io';

import 'app_logger.dart';

/// Records unhandled errors: a log line and a crash file next to the log, so a
/// crash that kills the app is still there on the next start. The files stay
/// on this machine.
class CrashReporter {
  /// Creates a reporter that keeps the last [keep] crash files in [directory].
  CrashReporter({
    required this.directory,
    required this.logger,
    this.keep = 10,
    DateTime Function() now = DateTime.now,
  }) : _now = now;

  /// Where `crash-<time>.txt` files go.
  final Directory directory;

  /// The app log.
  final AppLogger logger;

  /// How many crash files are kept.
  final int keep;

  final DateTime Function() _now;

  /// Records [error]. [fatal] marks errors that end the app. Never throws.
  void record(Object error, StackTrace stack, {bool fatal = false}) {
    logger.error(
      fatal ? 'fatal error' : 'unhandled error',
      error: error,
      stack: stack,
    );
    try {
      directory.createSync(recursive: true);
      final stamp = _now().toUtc().toIso8601String().replaceAll(':', '-');
      final file = File(
        '${directory.path}${Platform.pathSeparator}crash-$stamp.txt',
      );
      // Reuse the logger's redaction for the report's text.
      final text = logger.redactor.redact('$error\n$stack');
      file.writeAsStringSync('${fatal ? 'FATAL' : 'ERROR'} $stamp\n$text\n');
      _prune();
    } on FileSystemException {
      // The log line above is all we can keep.
    }
  }

  /// The crash files, newest first.
  List<File> crashFiles() {
    if (!directory.existsSync()) return const [];
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((f) => f.uri.pathSegments.last.startsWith('crash-'))
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  void _prune() {
    final files = crashFiles();
    for (final f in files.skip(keep)) {
      f.deleteSync();
    }
  }
}
