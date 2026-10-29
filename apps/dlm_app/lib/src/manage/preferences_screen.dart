import 'dart:async';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';
import '../platform/startup.dart';
import '../prefs/pref_providers.dart';
import '../shell/feedback.dart';
import '../shell/shortcuts.dart';
import '../skin_registry.dart';
import 'shortcut_editor.dart';

/// The accent colours offered, by name. With none chosen the accent follows
/// the operating system (the brand accent when it reports none).
const Map<String, int> accentChoices = {
  'indigo': 0xFF4F5BD5,
  'blue': 0xFF0A84FF,
  'green': 0xFF30D158,
  'orange': 0xFFFF9F0A,
  'red': 0xFFFF453A,
  'purple': 0xFFBF5AF2,
  'pink': 0xFFFF375F,
};

/// How the app looks and asks: theme, accent, skin, row height and whether
/// deleting downloads asks first. Each change applies and is remembered at
/// once.
class PreferencesScreen extends ConsumerWidget {
  /// Creates the page.
  const PreferencesScreen({super.key});

  String _accentName(AppLocalizations l, String id) => switch (id) {
    'indigo' => l.pref_accent_indigo,
    'blue' => l.pref_accent_blue,
    'green' => l.pref_accent_green,
    'orange' => l.pref_accent_orange,
    'red' => l.pref_accent_red,
    'purple' => l.pref_accent_purple,
    'pink' => l.pref_accent_pink,
    _ => id,
  };

  String _skinName(AppLocalizations l, String id) => switch (id) {
    'macos' => l.pref_skin_macos,
    'fluent' => l.pref_skin_fluent,
    'adwaita' => l.pref_skin_adwaita,
    'breeze' => l.pref_skin_breeze,
    _ => id,
  };

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() change,
  ) async {
    try {
      await change();
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  /// The tray icon and finish notifications.
  Widget _presenceGroup(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tray = ref.watch(trayEnabledProvider);
    final notify = ref.watch(notifyOnFinishProvider);
    return DlmFormGroup(
      title: l.pref_notifications,
      children: [
        DlmFormRow(
          label: l.pref_tray,
          description: l.pref_tray_desc,
          control: DlmSwitch(
            value: tray,
            semanticLabel: l.pref_tray,
            onChanged: (v) =>
                unawaited(ref.read(trayEnabledProvider.notifier).set(v)),
          ),
        ),
        DlmFormRow(
          label: l.pref_notify,
          description: l.pref_notify_desc,
          control: DlmSwitch(
            value: notify,
            semanticLabel: l.pref_notify,
            onChanged: (v) =>
                unawaited(ref.read(notifyOnFinishProvider.notifier).set(v)),
          ),
        ),
        DlmFormRow(
          label: l.pref_clipboard,
          description: l.pref_clipboard_desc,
          control: DlmSwitch(
            value: ref.watch(clipboardWatchProvider),
            semanticLabel: l.pref_clipboard,
            onChanged: (v) =>
                unawaited(ref.read(clipboardWatchProvider.notifier).set(v)),
          ),
        ),
      ],
    );
  }

  /// Start at login, start hidden, and the daemon's own login item. Only the
  /// rows this computer can do show: a remote daemon has no login item here.
  Widget _startupGroup(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final login = ref.watch(loginItemEnabledProvider);
    final service = ref.watch(daemonServiceStatusProvider);
    final hidden = ref.watch(startMinimisedProvider);
    final hasService =
        ref.watch(daemonServiceProvider) != null &&
        ref.watch(activeProfileProvider).isLocal;
    return DlmFormGroup(
      title: l.pref_startup,
      children: [
        DlmFormRow(
          label: l.pref_login,
          description: l.pref_login_desc,
          control: DlmSwitch(
            value: login.value ?? false,
            semanticLabel: l.pref_login,
            onChanged: login.isLoading
                ? null
                : (v) => unawaited(
                    _change(
                      context,
                      ref,
                      () => ref
                          .read(loginItemEnabledProvider.notifier)
                          .set(enabled: v),
                    ),
                  ),
          ),
        ),
        DlmFormRow(
          label: l.pref_start_hidden,
          description: l.pref_start_hidden_desc,
          control: DlmSwitch(
            value: hidden,
            semanticLabel: l.pref_start_hidden,
            onChanged: (v) =>
                unawaited(ref.read(startMinimisedProvider.notifier).set(v)),
          ),
        ),
        if (hasService)
          DlmFormRow(
            label: l.pref_daemon_service,
            description: l.pref_daemon_service_desc,
            control: DlmSwitch(
              value: service.value?.installed ?? false,
              semanticLabel: l.pref_daemon_service,
              onChanged: service.isLoading
                  ? null
                  : (v) => unawaited(
                      _change(
                        context,
                        ref,
                        () => ref
                            .read(daemonServiceStatusProvider.notifier)
                            .set(enabled: v),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final themeChoice = ref.watch(themeChoiceProvider);
    final accent = ref.watch(accentProvider);
    final skin = ref.watch(skinOverrideProvider);
    final density = ref.watch(densityProvider);
    final confirm = ref.watch(confirmDeleteProvider);
    // A colour stored by an earlier version or another tool is not one of the
    // names, but it is not "the system's" either.
    final accentId =
        accentChoices.entries
            .where((e) => e.value == accent)
            .map((e) => e.key)
            .firstOrNull ??
        (accent == null ? null : 'custom');
    final gap = SizedBox(height: theme.metrics.spacing.lg);

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      children: [
        Text(
          l.pref_intro,
          style: theme.typography.body.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        gap,
        DlmFormGroup(
          title: l.pref_appearance,
          children: [
            DlmFormRow(
              label: l.pref_theme,
              control: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: DlmSegmented<ThemeChoice>(
                  value: themeChoice,
                  onChanged: (v) =>
                      unawaited(ref.read(themeChoiceProvider.notifier).set(v)),
                  options: [
                    DlmOption(
                      value: ThemeChoice.system,
                      label: l.pref_theme_system,
                    ),
                    DlmOption(
                      value: ThemeChoice.light,
                      label: l.pref_theme_light,
                    ),
                    DlmOption(
                      value: ThemeChoice.dark,
                      label: l.pref_theme_dark,
                    ),
                  ],
                ),
              ),
            ),
            DlmFormRow(
              label: l.pref_accent,
              control: SizedBox(
                width: 220,
                child: DlmDropdown<String?>(
                  semanticLabel: l.pref_accent,
                  value: accentId,
                  choices: [
                    DlmChoice(value: null, label: l.pref_accent_default),
                    for (final id in accentChoices.keys)
                      DlmChoice(value: id, label: _accentName(l, id)),
                    if (accentId == 'custom')
                      DlmChoice(value: 'custom', label: l.pref_accent_custom),
                  ],
                  onChanged: (id) {
                    // Keeping "custom" keeps the stored colour.
                    if (id == 'custom') return;
                    unawaited(
                      ref
                          .read(accentProvider.notifier)
                          .set(id == null ? null : accentChoices[id]),
                    );
                  },
                ),
              ),
            ),
            DlmFormRow(
              label: l.pref_skin,
              description: l.pref_skin_desc,
              control: SizedBox(
                width: 220,
                child: DlmDropdown<String?>(
                  semanticLabel: l.pref_skin,
                  value: skins.containsKey(skin) ? skin : null,
                  choices: [
                    DlmChoice(value: null, label: l.pref_skin_auto),
                    for (final id in skinIds)
                      DlmChoice(value: id, label: _skinName(l, id)),
                  ],
                  onChanged: (id) => unawaited(
                    ref.read(skinOverrideProvider.notifier).set(id),
                  ),
                ),
              ),
            ),
            DlmFormRow(
              label: l.pref_density,
              control: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: DlmSegmented<Density>(
                  value: density,
                  onChanged: (v) =>
                      unawaited(ref.read(densityProvider.notifier).set(v)),
                  options: [
                    DlmOption(
                      value: Density.comfortable,
                      label: l.view_density_comfortable,
                    ),
                    DlmOption(
                      value: Density.compact,
                      label: l.view_density_compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        gap,
        _startupGroup(context, ref),
        gap,
        _presenceGroup(context, ref),
        gap,
        DlmFormGroup(
          title: l.pref_units,
          children: [
            DlmFormRow(
              label: l.pref_units,
              control: SizedBox(
                width: 220,
                child: DlmDropdown<UnitSystem>(
                  semanticLabel: l.pref_units,
                  value: ref.watch(unitSystemProvider),
                  choices: [
                    DlmChoice(value: UnitSystem.iec, label: l.pref_units_iec),
                    DlmChoice(value: UnitSystem.si, label: l.pref_units_si),
                  ],
                  onChanged: (v) =>
                      unawaited(ref.read(unitSystemProvider.notifier).set(v)),
                ),
              ),
            ),
            DlmFormRow(
              label: l.pref_language,
              control: SizedBox(
                width: 220,
                child: DlmDropdown<String?>(
                  semanticLabel: l.pref_language,
                  value: ref.watch(languageProvider),
                  choices: [
                    DlmChoice(value: null, label: l.pref_language_system),
                    for (final locale in AppLocalizations.supportedLocales)
                      DlmChoice(
                        value: locale.languageCode,
                        label: locale.languageCode,
                      ),
                  ],
                  onChanged: (code) =>
                      unawaited(ref.read(languageProvider.notifier).set(code)),
                ),
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.pref_shortcuts,
          children: const [ShortcutEditor()],
        ),
        gap,
        DlmFormGroup(
          title: l.pref_global,
          footer: ref.watch(globalHotkeysProvider).supported
              ? l.pref_global_desc
              : l.pref_global_unsupported,
          children: [
            if (ref.watch(globalHotkeysProvider).supported)
              const ShortcutEditor(ids: globalShortcutIds, clearable: true),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.pref_confirmations,
          children: [
            DlmFormRow(
              label: l.pref_confirm_delete,
              description: l.pref_confirm_delete_desc,
              control: DlmSwitch(
                value: confirm,
                semanticLabel: l.pref_confirm_delete,
                onChanged: (v) =>
                    unawaited(ref.read(confirmDeleteProvider.notifier).set(v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
