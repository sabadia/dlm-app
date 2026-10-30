import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/about/diagnostics_providers.dart';
import 'src/app.dart';
import 'src/connection/connection_controller.dart';
import 'src/connection/local_daemon.dart';
import 'src/crash_handlers.dart';
import 'src/platform/activity.dart';
import 'src/platform/instance_open.dart';
import 'src/platform/startup.dart';
import 'src/prefs/pref_providers.dart';
import 'src/secret_token_vault.dart';
import 'src/shell/app_shell.dart';

/// The daemon release this build ships with (`--dart-define`), or empty.
const String _bundledDaemonVersion = String.fromEnvironment(
  'DLM_DAEMON_VERSION',
);

void main(List<String> args) {
  // `args` are the program's own arguments (a file to open, a magnet: link,
  // --minimised). `Platform.executableArguments` would hold the Dart VM's flags
  // instead, so an open-with or a link click on Windows and Linux was lost.
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
    await WindowManagerControl.ensureInitialized();

    final prefs = await PreferencesStore.open(File(dirs.preferencesFile));
    final profiles = ProfileStore(
      file: File(dirs.profilesFile),
      vault: SecretTokenVault(PlatformSecretStore()),
    );
    // Read before the first frame: a remote profile in use must not start the
    // bundled daemon first.
    final savedProfiles = await profiles.load();
    const locator = DaemonLocator();
    final executable = locator.find();
    final login = platformLoginItem(
      flatpakMarker: File('${dirs.root}/login-item-enabled'),
    );
    final atLogin = await login.startedAtLogin(args);
    final claim = await InstanceEndpoint(Directory(dirs.root)).claim(args);
    if (claim is InstanceHandedOff) {
      logger.info('another instance is running; handed off and exiting');
      exit(0);
    }
    final primary = claim as InstancePrimary;
    final native = NativeOpenEvents();
    await native.start();
    final daemon = executable == null
        ? MissingDaemon(locator.candidates())
        : SupervisedDaemon(
            DaemonSupervisor(
              executable: executable,
              home: dirs.daemonHome,
              // Set by the packaging scripts: after an update a daemon of an
              // older version that is still running is replaced.
              expectedVersion: _bundledDaemonVersion.isEmpty
                  ? null
                  : _bundledDaemonVersion,
            ),
          );

    runApp(
      ProviderScope(
        // A refusal (403, 404) is not retried; only an unreachable daemon is.
        retry: dlmRetry,
        overrides: [
          connectedSessionOverride,
          connectedTaskStoreOverride,
          appLoggerProvider.overrideWithValue(logger),
          redactorProvider.overrideWithValue(redactor),
          preferencesProvider.overrideWithValue(prefs),
          profileStoreProvider.overrideWithValue(profiles),
          initialProfilesProvider.overrideWithValue(savedProfiles),
          localDaemonProvider.overrideWithValue(daemon),
          windowChromeProvider.overrideWithValue(platformWindowChrome()),
          globalHotkeysProvider.overrideWithValue(HotkeyManagerGlobalHotkeys()),
          loginItemProvider.overrideWithValue(login),
          trayProvider.overrideWithValue(TrayManagerController()),
          windowControlProvider.overrideWithValue(WindowManagerControl()),
          notifierProvider.overrideWithValue(
            LocalDesktopNotifier(appName: 'DLM'),
          ),
          startedAtLoginProvider.overrideWithValue(atLogin),
          awakeLockProvider.overrideWithValue(PlatformAwakeLock()),
          openingsProvider.overrideWithValue(
            Openings(
              launch: primary.launch,
              later: primary.incoming,
              native: native.events,
            ),
          ),
          if (executable != null)
            daemonServiceProvider.overrideWithValue(
              DaemonService(executable: executable, home: dirs.daemonHome),
            ),
          systemAppearanceProvider.overrideWithValue(
            platformSystemAppearance(),
          ),
        ],
        child: const DlmApp(),
      ),
    );
  });
}
