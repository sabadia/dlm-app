import 'dart:io';
import 'dart:ui';

import 'package:dlm_app/src/crash_handlers.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late CrashReporter reporter;
  late FlutterExceptionHandler? originalFlutter;
  late ErrorCallback? originalPlatform;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_crash');
    final logger = AppLogger(directory: dir, redactor: Redactor());
    reporter = CrashReporter(directory: dir, logger: logger);
    originalFlutter = FlutterError.onError;
    originalPlatform = PlatformDispatcher.instance.onError;
  });
  tearDown(() {
    FlutterError.onError = originalFlutter;
    PlatformDispatcher.instance.onError = originalPlatform;
    dir.deleteSync(recursive: true);
  });

  test('platform errors are recorded as fatal and handled', () {
    installCrashHandlers(reporter);
    final handled = PlatformDispatcher.instance.onError!(
      StateError('boom'),
      StackTrace.current,
    );
    expect(handled, isTrue);
    final file = reporter.crashFiles().single;
    expect(file.readAsStringSync(), startsWith('FATAL'));
    expect(file.readAsStringSync(), contains('boom'));
  });

  test('framework errors are recorded as errors', () {
    installCrashHandlers(reporter);
    FlutterError.onError!(
      FlutterErrorDetails(exception: Exception('widget failed')),
    );
    expect(
      reporter.crashFiles().single.readAsStringSync(),
      startsWith('ERROR'),
    );
  });

  test('errors in a guarded zone are recorded', () async {
    runGuarded(reporter, () => Future<void>.error(StateError('late')));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(reporter.crashFiles().single.readAsStringSync(), contains('late'));
  });
}
