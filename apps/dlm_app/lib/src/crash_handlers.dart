import 'dart:async';

import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/foundation.dart';

/// Sends every unhandled error to the [reporter] (a log line and a crash file
/// on this machine; nothing is sent anywhere).
///
/// Framework errors (a widget failing to build) are non-fatal: the app keeps
/// running. Errors that reach the platform dispatcher or the root zone are
/// recorded as fatal.
void installCrashHandlers(CrashReporter reporter) {
  FlutterError.onError = (details) {
    reporter.record(details.exception, details.stack ?? StackTrace.empty);
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.record(error, stack, fatal: true);
    return true; // handled: do not terminate
  };
}

/// Runs [body] in a zone whose uncaught errors go to [reporter].
void runGuarded(CrashReporter reporter, void Function() body) {
  runZonedGuarded(
    body,
    (error, stack) => reporter.record(error, stack, fatal: true),
  );
}
