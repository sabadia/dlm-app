import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../add/add_dialog.dart';
import '../onboarding/setup_dialog.dart';
import '../prefs/pref_providers.dart';
import '../routing/app_routes.dart';
import 'queue_commands.dart';
import 'shell_state.dart';
import 'shortcuts.dart';

/// The localised name of a downloads filter.
String filterLabel(AppLocalizations l, DownloadsFilter f) => switch (f) {
  DownloadsFilter.all => l.nav_all,
  DownloadsFilter.active => l.nav_active,
  DownloadsFilter.queued => l.nav_queued,
  DownloadsFilter.paused => l.nav_paused,
  DownloadsFilter.completed => l.nav_completed,
  DownloadsFilter.failed => l.nav_failed,
};

/// The icon of a downloads filter.
DlmIconName filterIcon(DownloadsFilter f) => switch (f) {
  DownloadsFilter.all => DlmIconName.download,
  DownloadsFilter.active => DlmIconName.speed,
  DownloadsFilter.queued => DlmIconName.schedule,
  DownloadsFilter.paused => DlmIconName.pause,
  DownloadsFilter.completed => DlmIconName.success,
  DownloadsFilter.failed => DlmIconName.error,
};

/// The commands of the palette: go to each page, plus window commands. More
/// are added by the features (add a download, pause all, ...).
List<DlmCommand> buildCommands(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context);
  final router = GoRouter.of(context);
  final mac = defaultTargetPlatform == TargetPlatform.macOS;
  final chords = effectiveShortcuts(
    ref.read(shortcutsProvider),
    primaryIsMeta: mac,
  );
  String? chord(String id) => chords[id]?.label(mac: mac);
  final queues = ref.read(queuesProvider).value ?? const [];
  return [
    for (final f in DownloadsFilter.values)
      DlmCommand(
        id: 'go.${f.name}',
        label: l.command_go_to(filterLabel(l, f)),
        group: l.nav_label,
        onInvoke: () => router.go(downloadsPath(f)),
      ),
    for (final q in queues)
      DlmCommand(
        id: 'go.queue.${q.id}',
        label: l.command_go_to(q.name),
        group: l.nav_queues,
        onInvoke: () => router.go(queuePath(q.id)),
      ),
    DlmCommand(
      id: 'download.add',
      label: l.cmd_add,
      shortcut: chord('download.add'),
      onInvoke: () => showAddDownload(context, ref),
    ),
    DlmCommand(
      id: 'queue.new',
      label: l.queue_new,
      group: l.nav_queues,
      onInvoke: () => createQueue(context, ref),
    ),
    DlmCommand(
      id: 'app.setup',
      label: l.cmd_setup,
      onInvoke: () => showSetup(context, ref),
    ),
    DlmCommand(
      id: 'window.focusSearch',
      label: l.command_focus_search,
      shortcut: chord('window.focusSearch'),
      onInvoke: ref.read(focusSearchProvider.notifier).request,
    ),
    DlmCommand(
      id: 'window.toggleInspector',
      label: l.command_toggle_inspector,
      onInvoke: () => ref
          .read(inspectorVisibleProvider.notifier)
          .set(!ref.read(inspectorVisibleProvider)),
    ),
  ];
}
