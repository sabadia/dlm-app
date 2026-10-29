import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The login item of the app; `main` overrides it with the platform's.
final loginItemProvider = Provider<LoginItem>(
  (ref) => const UnsupportedLoginItem(),
);

/// The daemon's own login item, or null when no daemon binary was found or
/// the daemon is not the app's own; `main` overrides it.
final daemonServiceProvider = Provider<DaemonService?>((ref) => null);

/// Whether the app starts at login, and the way to change it.
class LoginItemController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(loginItemProvider).isEnabled();

  /// Adds or removes the login item; a refusal is thrown and the state shows
  /// what the system says now.
  Future<void> set({required bool enabled}) async {
    final item = ref.read(loginItemProvider);
    try {
      await item.setEnabled(enabled: enabled);
    } finally {
      state = AsyncData(await item.isEnabled());
    }
  }
}

/// Whether the app starts at login.
final loginItemEnabledProvider =
    AsyncNotifierProvider<LoginItemController, bool>(LoginItemController.new);

/// Whether the daemon starts at login on its own, and the way to change it.
class DaemonServiceController extends AsyncNotifier<DaemonServiceStatus?> {
  @override
  Future<DaemonServiceStatus?> build() async =>
      ref.watch(daemonServiceProvider)?.status();

  /// Installs (and starts) or removes the daemon's login item.
  Future<void> set({required bool enabled}) async {
    final service = ref.read(daemonServiceProvider);
    if (service == null) return;
    final next = enabled ? await service.install() : await service.uninstall();
    state = AsyncData(next);
  }
}

/// The daemon's own login item.
final daemonServiceStatusProvider =
    AsyncNotifierProvider<DaemonServiceController, DaemonServiceStatus?>(
      DaemonServiceController.new,
    );

/// The tray icon of the app; `main` overrides it with the platform's.
final trayProvider = Provider<TrayController>((ref) => const UnsupportedTray());

/// The one window; `main` overrides it with the platform's.
final windowControlProvider = Provider<WindowControl>(
  (ref) => const UnsupportedWindowControl(),
);

/// Desktop notifications; `main` overrides it with the platform's.
final notifierProvider = Provider<DesktopNotifier>(
  (ref) => const UnsupportedDesktopNotifier(),
);

/// Whether the system started this run at login; `main` sets it.
final startedAtLoginProvider = Provider<bool>((ref) => false);
