import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../about/diagnostics_providers.dart';
import '../connection/connection_controller.dart';

/// Writes the native-messaging registration again for the browsers that
/// already have one.
///
/// The launcher the browsers start points into this app. When the app is moved
/// or reinstalled, or its daemon changes, the registration goes stale and the
/// extension can no longer find DLM; registering again is idempotent and
/// brings it up to date. Browsers with no registration are left alone: the
/// user chooses those on the Access page. Only the daemon of this computer has
/// a host, so a remote profile does nothing.
///
/// Returns the browsers it registered again.
final nativeHostUpkeepProvider = FutureProvider<List<String>>((ref) async {
  if (!ref.watch(activeProfileProvider).isLocal) return const [];
  // Only a connected app can ask the daemon. Reading the repository before
  // that throws, and a provider that failed once is not run again; watching
  // the connection runs this when it becomes ready.
  if (ref.watch(connectionProvider) is! Ready) return const [];
  final repo = ref.watch(daemonRepositoryProvider);
  try {
    final status = await repo.nativeHost();
    final installed = [
      for (final r in status.browsers ?? const <Result>[])
        if (r.status == 'installed') r.browser,
    ];
    if (installed.isEmpty) return const [];
    await repo.updateNativeHost(
      NativeHostRequestAction.install,
      browsers: installed,
    );
    return installed;
  } on Object catch (e) {
    // Not an admin of this daemon, or an old daemon: nothing to keep up.
    ref.read(appLoggerProvider).warning('native host upkeep skipped: $e');
    return const [];
  }
});
