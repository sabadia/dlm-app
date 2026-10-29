import 'dart:async';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../platform/startup.dart';
import '../prefs/pref_providers.dart';
import '../routing/app_routes.dart';
import 'app_commands.dart';
import 'shortcuts.dart';

/// One menu in the menu bar.
class ApplicationMenu {
  /// Creates a menu.
  const ApplicationMenu({required this.label, required this.entries});

  /// The menu's name.
  final String label;

  /// Its commands and separators.
  final List<ApplicationMenuEntry> entries;
}

/// A command or a separator in an [ApplicationMenu].
sealed class ApplicationMenuEntry {
  const ApplicationMenuEntry();
}

/// A command.
class ApplicationMenuItem extends ApplicationMenuEntry {
  /// Creates a command.
  const ApplicationMenuItem({
    required this.id,
    required this.label,
    required this.onSelected,
    this.shortcut,
    this.activator,
  });

  /// Stable identifier.
  final String id;

  /// The visible, localised text.
  final String label;

  /// Runs the command.
  final VoidCallback onSelected;

  /// The shortcut as text, for the in-window menu.
  final String? shortcut;

  /// The shortcut the native menu bar shows and handles.
  final SingleActivator? activator;
}

/// A line between groups.
class ApplicationMenuSeparator extends ApplicationMenuEntry {
  /// Creates a separator.
  const ApplicationMenuSeparator();
}

/// The application menus. [mac] puts About and Quit in the application menu
/// instead of Help and File, which is where macOS keeps them.
List<ApplicationMenu> buildApplicationMenus(
  BuildContext context,
  WidgetRef ref, {
  required bool mac,
  required VoidCallback openPalette,
}) {
  final l = AppLocalizations.of(context);
  final router = GoRouter.of(context);
  final chords = effectiveShortcuts(
    ref.read(shortcutsProvider),
    primaryIsMeta: mac,
  );
  String? shortcut(String id) => chords[id]?.label(mac: mac);
  SingleActivator? activator(String id) => chords[id]?.activator();
  final commands = buildCommands(context, ref);
  ApplicationMenuItem? command(String id) {
    for (final item in commands) {
      if (item.id == id) {
        return ApplicationMenuItem(
          id: item.id,
          label: item.label,
          shortcut: shortcut(item.id),
          activator: activator(item.id),
          onSelected: item.onInvoke,
        );
      }
    }
    return null;
  }

  final go = [
    for (final item in commands)
      if (item.id.startsWith('go.') && !item.id.startsWith('go.queue.'))
        ApplicationMenuItem(
          id: item.id,
          label: item.label,
          onSelected: item.onInvoke,
        ),
  ];
  final queues = [
    for (final item in commands)
      if (item.id.startsWith('go.queue.'))
        ApplicationMenuItem(
          id: item.id,
          label: item.label,
          onSelected: item.onInvoke,
        ),
  ];
  final about = ApplicationMenuItem(
    id: 'app.about',
    label: l.menu_about,
    onSelected: () => router.go(managePath('about')),
  );
  final quit = ApplicationMenuItem(
    id: 'app.quit',
    label: l.tray_quit,
    activator: SingleActivator(
      LogicalKeyboardKey.keyQ,
      meta: mac,
      control: !mac,
    ),
    shortcut: mac ? '⌘Q' : 'Ctrl+Q',
    onSelected: () => unawaited(ref.read(windowControlProvider).quit()),
  );

  return [
    if (mac)
      ApplicationMenu(
        label: l.app_name,
        entries: [about, const ApplicationMenuSeparator(), quit],
      ),
    ApplicationMenu(
      label: l.menu_file,
      entries: [
        ?command('download.add'),
        ?command('queue.new'),
        ?command('app.setup'),
        const ApplicationMenuSeparator(),
        ApplicationMenuItem(
          id: 'download.pauseAll',
          label: l.tray_pause_all,
          onSelected: () => unawaited(ref.read(taskActionsProvider).pauseAll()),
        ),
        ApplicationMenuItem(
          id: 'download.resumeAll',
          label: l.tray_resume_all,
          onSelected: () =>
              unawaited(ref.read(taskActionsProvider).resumeAll()),
        ),
        if (!mac) ...[const ApplicationMenuSeparator(), quit],
      ],
    ),
    ApplicationMenu(
      label: l.menu_go,
      entries: [
        ...go,
        if (queues.isNotEmpty) ...[const ApplicationMenuSeparator(), ...queues],
      ],
    ),
    ApplicationMenu(
      label: l.menu_window,
      entries: [
        ApplicationMenuItem(
          id: 'window.commandPalette',
          label: l.toolbar_palette,
          shortcut: shortcut('window.commandPalette'),
          activator: activator('window.commandPalette'),
          onSelected: openPalette,
        ),
        ?command('window.focusSearch'),
        ?command('window.toggleInspector'),
      ],
    ),
    if (!mac) ApplicationMenu(label: l.menu_help, entries: [about]),
  ];
}

/// The same menus as the native menu bar sends them.
List<PlatformMenuItem> platformMenuItems(
  List<ApplicationMenu> menus, {
  required bool mac,
}) {
  final items = <PlatformMenuItem>[
    for (final menu in menus) ?_platformMenu(menu, mac: mac),
  ];
  return items;
}

PlatformMenu? _platformMenu(ApplicationMenu menu, {required bool mac}) {
  ApplicationMenuItem? item(String id) {
    for (final entry in menu.entries) {
      if (entry is ApplicationMenuItem && entry.id == id) return entry;
    }
    return null;
  }

  final about = item('app.about');
  final quit = item('app.quit');
  if (mac && about != null && quit != null) {
    final hide = _provided(const [
      PlatformProvidedMenuItemType.hide,
      PlatformProvidedMenuItemType.hideOtherApplications,
    ]);
    return PlatformMenu(
      label: menu.label,
      menus: [
        _leaf(about),
        if (hide.isNotEmpty) PlatformMenuItemGroup(members: hide),
        _leaf(quit),
      ],
    );
  }

  final leaves = _leaves(menu.entries);
  if (leaves.isEmpty) return null;
  final windowExtras = mac && item('window.commandPalette') != null
      ? _provided(const [
          PlatformProvidedMenuItemType.minimizeWindow,
          PlatformProvidedMenuItemType.zoomWindow,
          PlatformProvidedMenuItemType.toggleFullScreen,
        ])
      : const <PlatformMenuItem>[];
  return PlatformMenu(
    label: menu.label,
    menus: [
      ...leaves,
      if (windowExtras.isNotEmpty) PlatformMenuItemGroup(members: windowExtras),
    ],
  );
}

PlatformMenuItem _leaf(ApplicationMenuItem item) => PlatformMenuItem(
  label: item.label,
  shortcut: item.activator,
  onSelected: item.onSelected,
);

List<PlatformMenuItem> _leaves(List<ApplicationMenuEntry> entries) {
  final groups = <List<PlatformMenuItem>>[<PlatformMenuItem>[]];
  for (final entry in entries) {
    switch (entry) {
      case ApplicationMenuSeparator():
        if (groups.last.isNotEmpty) groups.add([]);
      case ApplicationMenuItem(
        :final label,
        :final activator,
        :final onSelected,
      ):
        groups.last.add(
          PlatformMenuItem(
            label: label,
            shortcut: activator,
            onSelected: onSelected,
          ),
        );
    }
  }
  final filled = [
    for (final group in groups)
      if (group.isNotEmpty) group,
  ];
  if (filled.isEmpty) return const [];
  if (filled.length == 1) return filled.single;
  return [for (final group in filled) PlatformMenuItemGroup(members: group)];
}

List<PlatformMenuItem> _provided(List<PlatformProvidedMenuItemType> types) => [
  for (final type in types)
    if (PlatformProvidedMenuItem.hasMenu(type))
      PlatformProvidedMenuItem(type: type),
];

/// The in-window menu bar used where the system has no global menu bar.
class ApplicationMenuStrip extends StatelessWidget {
  /// Creates the strip.
  const ApplicationMenuStrip({required this.menus, super.key});

  /// The menus, in order.
  final List<ApplicationMenu> menus;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return SizedBox(
      height: theme.metrics.controlHeightSmall,
      child: Row(
        children: [
          for (final menu in menus)
            DlmMenuButton(
              label: menu.label,
              variant: DlmButtonVariant.plain,
              size: DlmControlSize.small,
              entries: [
                for (final entry in menu.entries)
                  switch (entry) {
                    ApplicationMenuSeparator() => const DlmMenuSeparator(),
                    ApplicationMenuItem(
                      :final label,
                      :final shortcut,
                      :final onSelected,
                    ) =>
                      DlmMenuItem(
                        label: label,
                        shortcut: shortcut,
                        onPressed: onSelected,
                      ),
                  },
              ],
            ),
        ],
      ),
    );
  }
}
