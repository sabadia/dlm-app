import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/connection/connection_controller.dart';
import 'src/connection/local_daemon.dart';
import 'src/crash_handlers.dart';
import 'src/prefs/pref_providers.dart';
import 'src/secret_token_vault.dart';
import 'src/shell/app_shell.dart';

void main() {
  // Everything, including the binding, starts inside the guarded zone: Flutter
  // insists that the binding and runApp share one.
  final dirs = AppDirs.resolve();
  final logs = Directory(dirs.logs);
  final redactor = Redactor(
    homeDirectory:
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'],
  );
  final logger = AppLogger(directory: logs, redactor: redactor);
  final crashes = CrashReporter(directory: logs, logger: logger);
  runGuarded(crashes, () async {
    WidgetsFlutterBinding.ensureInitialized();
    installCrashHandlers(crashes);
    logger.info('dlm app starting');

    final prefs = await PreferencesStore.open(File(dirs.preferencesFile));
    final profiles = ProfileStore(
      file: File(dirs.profilesFile),
      vault: SecretTokenVault(PlatformSecretStore()),
    );
    const locator = DaemonLocator();
    final executable = locator.find();
    final daemon = executable == null
        ? MissingDaemon(locator.candidates())
        : SupervisedDaemon(
            DaemonSupervisor(executable: executable, home: dirs.daemonHome),
          );

    runApp(
      ProviderScope(
        overrides: [
          connectedSessionOverride,
          connectedTaskStoreOverride,
          preferencesProvider.overrideWithValue(prefs),
          profileStoreProvider.overrideWithValue(profiles),
          localDaemonProvider.overrideWithValue(daemon),
          windowChromeProvider.overrideWithValue(platformWindowChrome()),
          systemAppearanceProvider.overrideWithValue(
            platformSystemAppearance(),
          ),
        ],
        child: const DlmApp(),
      ),
    );
  });
}
