import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../add/add_dialog.dart';
import '../inspector/inspector_pane.dart';
import '../manage/manage_screen.dart';
import '../onboarding/setup_dialog.dart';
import '../platform/activity.dart';
import '../platform/clipboard_watch.dart';
import '../platform/instance_open.dart';
import '../platform/window_placement.dart';
import '../prefs/pref_providers.dart';
import '../queues/queue_countdown.dart';
import '../routing/app_routes.dart';
import '../screens/list_views.dart';
import '../settings/settings_form.dart';
import 'app_commands.dart';
import 'queue_commands.dart';
import 'shell_state.dart';
import 'shortcuts.dart';
import 'status_banners.dart';
import 'status_bar.dart';
import 'task_commands.dart';

/// The window's window chrome (macOS glass); overridden with the platform's.
final windowChromeProvider = Provider<WindowChrome>(
  (ref) => const UnsupportedWindowChrome(),
);

/// The toasts of the window.
final toastControllerProvider = Provider<DlmToastController>((ref) {
  final controller = DlmToastController();
  ref.onDispose(controller.dispose);
  return controller;
});

/// The frame of the app: sidebar, toolbar, content, details pane. The routed
/// page is [child].
class AppShell extends ConsumerStatefulWidget {
  /// Creates the shell for the page at [location].
  const AppShell({required this.location, required this.child, super.key});

  /// The current location, to highlight the sidebar item and title the page.
  final Uri location;

  /// The routed page.
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final FocusNode _search = FocusNode(debugLabel: 'toolbar search');

  @override
  void initState() {
    super.initState();
    ref.listenManual(addRequestProvider, (previous, next) {
      if (previous == null || next == previous || !mounted) return;
      unawaited(showAddDownload(context, ref));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(showSetupOnFirstRun(context, ref));
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static int? _positive(int n) => n > 0 ? n : null;

  static String _manageTitle(AppLocalizations l, String page) => switch (page) {
    'categories' => l.nav_manage_categories,
    'logins' => l.nav_manage_logins,
    'cookies' => l.nav_manage_cookies,
    'webhooks' => l.nav_manage_webhooks,
    'plugins' => l.nav_manage_plugins,
    'browser' => l.nav_manage_browser,
    'transfer' => l.nav_manage_transfer,
    'statistics' => l.nav_manage_statistics,
    'daemon' => l.nav_manage_daemon,
    'access' => l.nav_manage_access,
    'preferences' => l.nav_manage_preferences,
    'about' => l.nav_manage_about,
    _ => page,
  };

  ({String sidebarId, String title}) _current(
    AppLocalizations l,
    List<Queue> queues,
    List<Category> categories,
  ) {
    final segments = widget.location.pathSegments;
    if (segments.length >= 2 && segments.first == 'manage') {
      final page = segments[1];
      return (sidebarId: manageSidebarId(page), title: _manageTitle(l, page));
    }
    if (segments.length >= 2 && segments.first == 'settings') {
      final group = segments[1];
      return (
        sidebarId: settingsSidebarId(group),
        title: '${l.nav_settings}: ${humaniseSetting(group)}',
      );
    }
    if (segments.length >= 2 && segments.first == 'categories') {
      final id = segments[1];
      final name = categories.where((c) => c.id == id).firstOrNull?.name ?? id;
      return (sidebarId: categorySidebarId(id), title: name);
    }
    if (segments.length >= 2 && segments.first == 'queues') {
      final id = segments[1];
      final name = queues.where((q) => q.id == id).firstOrNull?.name ?? id;
      return (sidebarId: queueSidebarId(id), title: name);
    }
    final filter =
        DownloadsFilter.fromSegment(
          segments.length >= 2 ? segments[1] : null,
        ) ??
        DownloadsFilter.all;
    return (
      sidebarId: downloadsSidebarId(filter),
      title: filterLabel(l, filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final queues = ref.watch(queuesProvider).value ?? const <Queue>[];
    final counts = ref.watch(queueCountsProvider);
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final current = _current(l, queues, categories);
    final sidebarWidth = ref.watch(sidebarWidthProvider);
    final inspectorWidth = ref.watch(inspectorWidthProvider);
    final inspectorPreferred = ref.watch(inspectorVisibleProvider);
    final selected = ref.watch(selectedTasksProvider);
    // The view menu shows the engine filter and the saved views.
    ref
      ..watch(listOptionsProvider)
      ..watch(savedViewsProvider)
      ..watch(densityProvider)
      ..watch(downloadColumnsProvider);
    final ids = [for (final t in selected) t.id];
    final chrome = ref.watch(windowChromeProvider);
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;

    ref.listen(focusSearchProvider, (_, _) => _search.requestFocus());

    // Three panes need room: below this width the details pane stays closed
    // however it was left.
    final inspectorVisible =
        inspectorPreferred && MediaQuery.sizeOf(context).width >= 1000;

    void openPalette() => showDlmCommandPalette(
      context,
      commands: buildCommands(context, ref),
      labels: DlmPaletteLabels(
        placeholder: l.palette_placeholder,
        noResults: l.palette_no_results,
        semanticLabel: l.palette_label,
      ),
    );

    final sidebar = DlmSidebar<String>(
      semanticLabel: l.nav_label,
      selected: current.sidebarId,
      onSelected: (id) async {
        // Edits that were not saved are not thrown away without asking.
        if (ref.read(unsavedSettingsProvider)) {
          final leave = await showDlmConfirm(
            context,
            title: l.settings_leave_title,
            message: l.settings_leave_message,
            confirmLabel: l.settings_leave_confirm,
            cancelLabel: l.settings_leave_stay,
            destructive: true,
          );
          if (!leave || !context.mounted) return;
          ref.read(unsavedSettingsProvider.notifier).mark(dirty: false);
        }
        if (!context.mounted) return;
        if (id.startsWith('manage:')) {
          context.go(managePath(id.substring('manage:'.length)));
        } else if (id.startsWith('settings:')) {
          context.go(settingsPath(id.substring('settings:'.length)));
        } else if (id.startsWith('queue:')) {
          context.go(queuePath(id.substring('queue:'.length)));
        } else if (id.startsWith('category:')) {
          context.go(categoryPath(id.substring('category:'.length)));
        } else {
          final f = DownloadsFilter.fromSegment(
            id.substring('downloads:'.length),
          );
          if (f != null) context.go(downloadsPath(f));
        }
      },
      header: SizedBox(height: theme.titleBarInset + theme.metrics.spacing.sm),
      footer: Padding(
        padding: EdgeInsets.all(theme.metrics.spacing.sm),
        child: DlmButton(
          label: l.queue_new,
          icon: const DlmIcon(DlmIconName.plus),
          variant: DlmButtonVariant.plain,
          onPressed: () => createQueue(context, ref),
        ),
      ),
      sections: [
        DlmSidebarSection(
          items: [
            for (final f in DownloadsFilter.values)
              DlmSidebarItem(
                id: downloadsSidebarId(f),
                label: filterLabel(l, f),
                icon: DlmIcon(filterIcon(f)),
                count: _positive(counts.count(statuses: f.statuses)),
              ),
          ],
        ),
        if (queues.isNotEmpty)
          DlmSidebarSection(
            title: l.nav_queues,
            items: [
              for (final q in queues)
                DlmSidebarItem(
                  id: queueSidebarId(q.id),
                  label: q.name,
                  icon: const DlmIcon(DlmIconName.queue),
                  count: _positive(counts.open(q.id)),
                  // Downloads dropped on a queue move to it.
                  onDrop: (data) {
                    if (data is! TaskDragData) return false;
                    unawaited(moveTasksToQueue(context, ref, data.ids, q));
                    return true;
                  },
                ),
            ],
          ),
        if (categories.isNotEmpty)
          DlmSidebarSection(
            title: l.nav_categories,
            items: [
              for (final c in categories)
                DlmSidebarItem(
                  id: categorySidebarId(c.id),
                  label: c.name,
                  icon: const DlmIcon(DlmIconName.tag),
                ),
            ],
          ),
        DlmSidebarSection(
          title: l.nav_tools,
          items: [
            for (final page in toolPages)
              DlmSidebarItem(
                id: manageSidebarId(page),
                label: _manageTitle(l, page),
                icon: DlmIcon(switch (page) {
                  'browser' => DlmIconName.globe,
                  'transfer' => DlmIconName.importIcon,
                  _ => DlmIconName.chart,
                }),
              ),
          ],
        ),
        DlmSidebarSection(
          title: l.nav_manage,
          items: [
            for (final page in setupPages)
              DlmSidebarItem(
                id: manageSidebarId(page),
                label: _manageTitle(l, page),
                icon: const DlmIcon(DlmIconName.tag),
              ),
          ],
        ),
        DlmSidebarSection(
          title: l.nav_settings,
          items: [
            for (final g in settingsGroups)
              DlmSidebarItem(
                id: settingsSidebarId(g),
                label: humaniseSetting(g),
                icon: const DlmIcon(DlmIconName.settings),
              ),
          ],
        ),
      ],
    );

    final content = Column(
      children: [
        DlmToolbar(
          semanticLabel: l.toolbar_label,
          title: current.title,
          actions: [
            DlmIconButton(
              icon: const DlmIcon(DlmIconName.plus),
              semanticLabel: l.toolbar_add,
              onPressed: () => showAddDownload(context, ref),
            ),
            if (selected.isNotEmpty) ...[
              Text(
                l.selection_count(selected.length),
                style: theme.typography.caption.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.pause),
                semanticLabel: l.action_pause,
                onPressed: selected.any((t) => t.statusKind.canPause)
                    ? () => pauseTasks(context, ref, ids)
                    : null,
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.play),
                semanticLabel: l.action_resume,
                onPressed: selected.any((t) => t.statusKind.canResume)
                    ? () => resumeTasks(context, ref, ids)
                    : null,
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.trash),
                semanticLabel: l.action_delete,
                onPressed: () => deleteTasks(context, ref, ids),
              ),
            ],
            DlmMenuButton(
              icon: const DlmIcon(DlmIconName.settings),
              semanticLabel: l.display_menu,
              variant: DlmButtonVariant.plain,
              entries: displayMenuEntries(context, ref),
            ),
            DlmMenuButton(
              icon: const DlmIcon(DlmIconName.filter),
              semanticLabel: l.view_menu,
              variant: DlmButtonVariant.plain,
              entries: viewMenuEntries(
                context,
                ref,
                filter:
                    DownloadsFilter.fromSegment(
                      widget.location.pathSegments.length >= 2
                          ? widget.location.pathSegments[1]
                          : null,
                    ) ??
                    DownloadsFilter.all,
              ),
            ),
            SizedBox(
              width: 220,
              child: DlmSearchField(
                focusNode: _search,
                placeholder: l.toolbar_search_placeholder,
                clearLabel: l.toolbar_search_clear,
                onChanged: ref.read(searchTextProvider.notifier).set,
              ),
            ),
            DlmIconButton(
              icon: const DlmIcon(DlmIconName.menu),
              semanticLabel: l.toolbar_palette,
              onPressed: openPalette,
            ),
            DlmIconButton(
              icon: const DlmIcon(DlmIconName.inspector),
              semanticLabel: inspectorPreferred
                  ? l.toolbar_inspector_hide
                  : l.toolbar_inspector_show,
              onPressed: () => ref
                  .read(inspectorVisibleProvider.notifier)
                  .set(!inspectorPreferred),
            ),
          ],
        ),
        const StatusBanners(),
        const ClipboardWatcher(),
        const InstanceOpenBinder(),
        const ActivityBinder(),
        const WindowPlacementBinder(),
        const ClipboardOfferBanner(),
        const QueueCountdownBanners(),
        Expanded(
          child: inspectorVisible
              ? DlmSplitView(
                  primaryAtEnd: true,
                  primarySize: inspectorWidth,
                  minPrimary: 280,
                  minSecondary: 360,
                  initialSize: 340,
                  dividerLabel: l.inspector_resize,
                  onResized: ref.read(inspectorWidthProvider.notifier).set,
                  secondary: widget.child,
                  primary: const InspectorPane(),
                )
              : widget.child,
        ),
        const StatusBar(),
      ],
    );

    final chords = effectiveShortcuts(
      ref.watch(shortcutsProvider),
      primaryIsMeta: isMac,
    );
    return CallbackShortcuts(
      bindings: {
        if (chords['window.commandPalette'] case final shortcut?)
          shortcut.activator(): openPalette,
        if (chords['window.focusSearch'] case final shortcut?)
          shortcut.activator(): () =>
              ref.read(focusSearchProvider.notifier).request(),
        if (chords['download.add'] case final shortcut?)
          shortcut.activator(): () => showAddDownload(context, ref),
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: theme.windowBackground,
          child: DlmToastHost(
            controller: ref.watch(toastControllerProvider),
            child: DlmSplitView(
              primarySize: sidebarWidth,
              minPrimary: theme.metrics.sidebarWidth.min,
              minSecondary: 520,
              initialSize: theme.metrics.sidebarWidth.ideal,
              dividerLabel: l.sidebar_resize,
              onResized: ref.read(sidebarWidthProvider.notifier).set,
              primary: BackdropRegion(
                chrome: chrome,
                child: theme.components.sidebarSurface(context, child: sidebar),
              ),
              secondary: ColoredBox(
                color: theme.colors.content,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
