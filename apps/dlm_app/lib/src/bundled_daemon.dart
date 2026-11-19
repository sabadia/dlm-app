import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The daemon release this build ships with (`--dart-define=DLM_DAEMON_VERSION`),
/// or empty in a development run.
const String bundledDaemonVersion = String.fromEnvironment(
  'DLM_DAEMON_VERSION',
);

/// [bundledDaemonVersion], as a provider so a test can name another.
final bundledDaemonVersionProvider = Provider<String>(
  (ref) => bundledDaemonVersion,
);
