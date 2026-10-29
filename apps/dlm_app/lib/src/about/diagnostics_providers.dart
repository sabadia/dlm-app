import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The version of this build. The release pipeline sets it with
/// `--dart-define=DLM_VERSION=1.2.3`.
const String appVersion = String.fromEnvironment(
  'DLM_VERSION',
  defaultValue: '0.0.0-dev',
);

/// The app's own log, opened in `main`.
final appLoggerProvider = Provider<AppLogger>(
  (ref) => throw StateError('override appLoggerProvider'),
);

/// What removes secrets from everything the app writes or copies, opened in
/// `main`.
final redactorProvider = Provider<Redactor>(
  (ref) => throw StateError('override redactorProvider'),
);
