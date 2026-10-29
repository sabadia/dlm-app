import 'dart:async';
import 'dart:math' as math;

import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../manage/manage_screen.dart';
import '../routing/app_routes.dart';
import '../settings/settings_form.dart';
import '../settings/settings_screen.dart';

/// The three groups of pages behind the gear button.
enum HubSection {
  /// Things to do: the browser tool, import and export, statistics.
  tools,

  /// What the app and the download service are set up with.
  manage,

  /// The download service's settings.
  settings,
}

/// The pages of [section], by their path segment.
List<String> hubPages(HubSection section) => switch (section) {
  HubSection.tools => toolPages,
  HubSection.manage => setupPages,
  HubSection.settings => settingsGroups,
};

/// The section a `/manage/<page>` page belongs to.
HubSection sectionOfManagePage(String page) =>
    toolPages.contains(page) ? HubSection.tools : HubSection.manage;

/// The name of a management page.
String manageTitle(AppLocalizations l, String page) => switch (page) {
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

/// The name of a page of [section].
String hubPageTitle(AppLocalizations l, HubSection section, String page) =>
    section == HubSection.settings
    ? humaniseSetting(page)
    : manageTitle(l, page);

/// The name of [section].
String hubSectionTitle(AppLocalizations l, HubSection section) =>
    switch (section) {
      HubSection.tools => l.nav_tools,
      HubSection.manage => l.nav_manage,
      HubSection.settings => l.nav_settings,
    };

/// The icon of a page: each one has its own, by what it is about.
DlmIconName hubPageIcon(HubSection section, String page) => switch (page) {
  // Settings groups.
  'general' => DlmIconName.settings,
  'speed' => DlmIconName.speed,
  'network' => DlmIconName.globe,
  'retry' => DlmIconName.restart,
  'refresh' => DlmIconName.refresh,
  'post-processing' => DlmIconName.wand,
  'torrent' => DlmIconName.magnet,
  'browser' =>
    section == HubSection.tools ? DlmIconName.globe : DlmIconName.externalLink,
  // Manage pages.
  'categories' => DlmIconName.tag,
  'logins' => DlmIconName.lock,
  'cookies' => DlmIconName.cookie,
  'webhooks' => DlmIconName.link,
  'plugins' => DlmIconName.plugin,
  'daemon' => DlmIconName.server,
  'access' => DlmIconName.key,
  'preferences' => DlmIconName.viewOptions,
  'about' => DlmIconName.info,
  // Tools.
  'transfer' => DlmIconName.importIcon,
  'statistics' => DlmIconName.chart,
  _ => DlmIconName.file,
};

/// The icon of [section] itself (the gear menu).
DlmIconName hubSectionIcon(HubSection section) => switch (section) {
  HubSection.tools => DlmIconName.chart,
  HubSection.manage => DlmIconName.folder,
  HubSection.settings => DlmIconName.settings,
};

/// Opens the settings window on [section], at [page] (the first page when
/// null).
Future<void> showSettingsHub(
  BuildContext context, {
  required HubSection section,
  String? page,
}) async {
  final l = AppLocalizations.of(context);
  await showDlmDialog<void>(
    context,
    semanticLabel: hubSectionTitle(l, section),
    maxWidth: 1280,
    builder: (_) => SettingsHub(section: section, page: page),
  );
}

/// A large window over the app: the pages of one section in a list on the
/// left and the chosen page on the right.
class SettingsHub extends ConsumerStatefulWidget {
  /// Creates the window on [section] at [page].
  const SettingsHub({required this.section, this.page, super.key});

  /// The pages shown.
  final HubSection section;

  /// The page to start on.
  final String? page;

  @override
  ConsumerState<SettingsHub> createState() => _SettingsHubState();
}

class _SettingsHubState extends ConsumerState<SettingsHub> {
  late String _page = hubPages(widget.section).contains(widget.page)
      ? widget.page!
      : hubPages(widget.section).first;

  /// Whether the user agreed to throw away unsaved edits.
  Future<bool> _mayLeave() async {
    if (!ref.read(unsavedSettingsProvider)) return true;
    final l = AppLocalizations.of(context);
    final leave = await showDlmConfirm(
      context,
      title: l.settings_leave_title,
      message: l.settings_leave_message,
      confirmLabel: l.settings_leave_confirm,
      cancelLabel: l.settings_leave_stay,
      destructive: true,
    );
    if (leave) ref.read(unsavedSettingsProvider.notifier).mark(dirty: false);
    return leave;
  }

  Future<void> _select(String page) async {
    if (page == _page || !await _mayLeave() || !mounted) return;
    setState(() => _page = page);
  }

  Future<void> _close() async {
    if (!await _mayLeave() || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final section = widget.section;
    final height = math
        .max(360, math.min(840, MediaQuery.sizeOf(context).height - 96))
        .toDouble();
    final body = section == HubSection.settings
        ? SettingsScreen(group: _page)
        : ManageScreen(page: _page);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.metrics.radii.container),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              SizedBox(
                width: 236,
                child: theme.components.sidebarSurface(
                  context,
                  child: DlmSidebar<String>(
                    semanticLabel: hubSectionTitle(l, section),
                    selected: _page,
                    onSelected: _select,
                    header: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        theme.metrics.spacing.lg,
                        theme.metrics.spacing.lg,
                        theme.metrics.spacing.lg,
                        theme.metrics.spacing.sm,
                      ),
                      child: Text(
                        hubSectionTitle(l, section),
                        style: theme.typography.subtitle,
                      ),
                    ),
                    sections: [
                      DlmSidebarSection(
                        items: [
                          for (final p in hubPages(section))
                            DlmSidebarItem(
                              id: p,
                              label: hubPageTitle(l, section, p),
                              icon: DlmIcon(hubPageIcon(section, p)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: theme.colors.content,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          theme.metrics.spacing.lg,
                          theme.metrics.spacing.md,
                          theme.metrics.spacing.sm,
                          theme.metrics.spacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                hubPageTitle(l, section, _page),
                                style: theme.typography.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DlmIconButton(
                              icon: const DlmIcon(DlmIconName.close),
                              semanticLabel: l.hub_close,
                              onPressed: _close,
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
