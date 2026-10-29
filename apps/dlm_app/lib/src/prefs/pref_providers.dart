import 'dart:async';

import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The preferences file; opened in `main` and overridden here.
final preferencesProvider = Provider<PreferencesStore>(
  (ref) => throw StateError('override preferencesProvider'),
);

/// One preference as state: reads the stored value, follows changes made
/// anywhere, and writes through [set].
class PrefNotifier<T> extends Notifier<T> {
  /// Creates the notifier for [pref].
  PrefNotifier(this.pref);

  /// The preference.
  final Pref<T> pref;

  @override
  T build() {
    final store = ref.watch(preferencesProvider);
    final sub = store.changes.listen((key) {
      if (key == pref.key && ref.mounted) state = store.get(pref);
    });
    ref.onDispose(() => unawaited(sub.cancel()));
    return store.get(pref);
  }

  /// Stores [value].
  Future<void> set(T value) {
    state = value;
    return ref.read(preferencesProvider).set(pref, value);
  }
}

/// Sidebar width.
final sidebarWidthProvider = NotifierProvider<PrefNotifier<double>, double>(
  () => PrefNotifier(UiPrefs.sidebarWidth),
);

/// Details pane width.
final inspectorWidthProvider = NotifierProvider<PrefNotifier<double>, double>(
  () => PrefNotifier(UiPrefs.inspectorWidth),
);

/// Whether the first-run setup was finished.
final onboardingDoneProvider = NotifierProvider<PrefNotifier<bool>, bool>(
  () => PrefNotifier(UiPrefs.onboardingDone),
);

/// Whether the details pane is open.
final inspectorVisibleProvider = NotifierProvider<PrefNotifier<bool>, bool>(
  () => PrefNotifier(UiPrefs.inspectorVisible),
);

/// Light, dark or system.
final themeChoiceProvider =
    NotifierProvider<PrefNotifier<ThemeChoice>, ThemeChoice>(
      () => PrefNotifier(UiPrefs.theme),
    );

/// Row density.
final densityProvider = NotifierProvider<PrefNotifier<Density>, Density>(
  () => PrefNotifier(UiPrefs.density),
);

/// Forced skin id, or null for the platform's.
final skinOverrideProvider = NotifierProvider<PrefNotifier<String?>, String?>(
  () => PrefNotifier(UiPrefs.skinOverride),
);

/// Accent colour override as ARGB, or null.
final accentProvider = NotifierProvider<PrefNotifier<int?>, int?>(
  () => PrefNotifier(UiPrefs.accent),
);

/// Whether deleting downloads asks first.
final confirmDeleteProvider = NotifierProvider<PrefNotifier<bool>, bool>(
  () => PrefNotifier(UiPrefs.confirmDelete),
);

/// Keep the window hidden when the app is started at login.
final startMinimisedProvider = NotifierProvider<PrefNotifier<bool>, bool>(
  () => PrefNotifier(UiPrefs.startMinimised),
);

/// Whether the tray / menu-bar icon shows.
final trayEnabledProvider = NotifierProvider<PrefNotifier<bool>, bool>(
  () => PrefNotifier(UiPrefs.trayEnabled),
);

/// Whether finished and failed downloads are announced.
final notifyOnFinishProvider = NotifierProvider<PrefNotifier<bool>, bool>(
  () => PrefNotifier(UiPrefs.notifyOnFinish),
);
