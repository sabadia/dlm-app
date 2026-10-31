import 'dart:async';
import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../about/diagnostics_providers.dart';
import '../connection/connection_controller.dart';
import '../format/dlm_format.dart';
import '../pairing/native_host_upkeep.dart';
import '../pairing/pairing_dialog.dart';
import '../pairing/pairing_requests.dart';
import '../prefs/pref_providers.dart';
import '../queues/queue_countdown.dart';
import '../refresh/link_requests.dart';
import '../shell/shell_state.dart';
import 'file_opener.dart';
import 'startup.dart';
import 'url_opener.dart';

/// The asset of the tray icon: a monochrome template in the macOS menu bar,
/// the coloured mark elsewhere.
final String trayIconAsset = defaultTargetPlatform == TargetPlatform.macOS
    ? 'assets/icon/tray_template.png'
    : 'assets/icon/dlm_32.png';

/// Ids of the tray menu lines.
abstract final class TrayIds {
  /// Brings the window forward.
  static const show = 'show';

  /// Pauses every download.
  static const pauseAll = 'pause-all';

  /// Resumes every download.
  static const resumeAll = 'resume-all';

  /// Opens the add dialog.
  static const add = 'add';

  /// Quits the app.
  static const quit = 'quit';
}

/// Ids of the buttons of a notification.
abstract final class NotifyIds {
  /// Open the file.
  static const open = 'open';

  /// Show the file in the file manager.
  static const folder = 'folder';

  /// Download again.
  static const retry = 'retry';

  /// The category of a finished download.
  static const completed = 'completed';

  /// The category of a failed download.
  static const failed = 'failed';

  /// The category of a queue that ran out of work.
  static const queue = 'queue';

  /// The category of a browser extension that asks to connect.
  static const pairing = 'pairing';

  /// The category of a download that waits for a new link.
  static const link = 'link';

  /// Open the page the download came from.
  static const openPage = 'open-page';
}

/// The buttons per notification category, which macOS needs at start-up.
Map<String, List<NotificationButton>> notificationCategories(
  AppLocalizations l,
) => {
  NotifyIds.completed: [
    NotificationButton(NotifyIds.open, l.notif_open),
    NotificationButton(NotifyIds.folder, l.notif_folder),
  ],
  NotifyIds.failed: [NotificationButton(NotifyIds.retry, l.notif_retry)],
  NotifyIds.link: [NotificationButton(NotifyIds.openPage, l.notif_open_page)],
};

/// Where the downloaded file of [task] is, or null when the daemon did not say.
String? taskFilePath(Task task) {
  final dir = task.dir;
  final name = task.name ?? task.resource?.name;
  if (dir == null || dir.isEmpty || name == null || name.isEmpty) return null;
  final sep = Platform.pathSeparator;
  return dir.endsWith(sep) || dir.endsWith('/') ? '$dir$name' : '$dir$sep$name';
}

/// Ties the window to the system: the tray icon and its menu, closing to the
/// tray, starting hidden at login, and notifications of finished and failed
/// downloads. It draws nothing of its own.
class IntegrationBinder extends ConsumerStatefulWidget {
  /// Wraps [child].
  const IntegrationBinder({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<IntegrationBinder> createState() => _IntegrationBinderState();
}

class _IntegrationBinderState extends ConsumerState<IntegrationBinder> {
  final List<StreamSubscription<Object?>> _subs = [];
  StreamSubscription<String>? _logs;
  List<TrayEntry>? _shownMenu;
  String? _shownTitle;
  String? _shownTooltip;
  bool _started = false;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    // Quitting (Command-Q, the system shutting down) stops the daemon the app
    // started, so an update can replace its files.
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        await _releaseDaemon();
        return AppExitResponse.exit;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_start()));
  }

  Future<void> _releaseDaemon() async {
    try {
      // With the daemon's own login item installed it keeps downloading when
      // the app quits, even if this app is the one that started it.
      final service = ref.read(daemonServiceStatusProvider).value;
      await ref
          .read(localDaemonProvider)
          .dispose(keepRunning: service?.installed ?? false);
    } on Object catch (e) {
      // Quitting must go on; a daemon that cannot be stopped is left to its
      // own shutdown. The log may not be up either.
      try {
        ref.read(appLoggerProvider).warning('stopping the daemon failed: $e');
      } on Object {
        // Nothing more to do.
      }
    }
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    unawaited(_logs?.cancel());
    super.dispose();
  }

  Future<void> _start() async {
    if (!mounted || _started) return;
    _started = true;
    final tray = ref.read(trayProvider);
    final window = ref.read(windowControlProvider);
    final notifier = ref.read(notifierProvider);

    _subs
      ..add(tray.selections.listen(_onTray))
      ..add(window.closeRequests.listen((_) => unawaited(_onClose())))
      ..add(notifier.taps.listen(_onTap));
    // Rebuilds of the menu follow the speed and the setting.
    ref
      ..listenManual(trayEnabledProvider, (_, _) => unawaited(_syncTray()))
      ..listenManual(
        systemSpeedProvider,
        (_, _) => unawaited(_syncTray()),
        // Nothing is connected for a while after the start.
        onError: (_, _) {},
      )
      ..listenManual(
        taskStoreProvider,
        (_, store) => _watchTasks(store),
        fireImmediately: true,
        onError: (_, _) {},
      )
      ..listenManual(pairingRequestsProvider, (previous, next) {
        // An extension that asks to connect needs an answer: bring the window
        // forward, where the prompt is, and tell the system.
        final before = {for (final p in previous ?? const <Pairing>[]) p.id};
        if (next.any((p) => !before.contains(p.id))) {
          unawaited(window.show());
          unawaited(_announcePairing(next.last));
        }
      })
      ..listenManual(linkRequestsProvider, (previous, next) {
        final before = {
          for (final r in previous ?? const <LinkRequest>[]) r.taskId,
        };
        for (final r in next) {
          if (!before.contains(r.taskId)) unawaited(_announceLink(r));
        }
      })
      ..listenManual(pendingQueueActionsProvider, (previous, next) {
        final before = previous?.keys.toSet() ?? const {};
        for (final entry in next.entries) {
          if (!before.contains(entry.key)) {
            unawaited(_announceQueue(entry.value));
          }
        }
      });
    // The registration of the browsers is brought up to date once the daemon
    // is connected (and again after a reconnect); the listener keeps the
    // provider alive so that it does.
    ref.listenManual(nativeHostUpkeepProvider, (_, _) {});
    final l = AppLocalizations.of(context);
    await notifier.init(categories: notificationCategories(l));
    // The daemon is not connected yet at this point; a failure here must not
    // keep a login launch from starting hidden.
    try {
      await _syncTray();
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('tray could not be set up yet: $e');
    }
    if (ref.read(startedAtLoginProvider) &&
        ref.read(startMinimisedProvider) &&
        tray.visible) {
      await window.hide();
    }
  }

  List<TrayEntry> _menu(AppLocalizations l) => [
    TrayEntry(TrayIds.show, l.tray_show),
    const TrayEntry.separator(),
    TrayEntry(TrayIds.add, l.tray_add),
    TrayEntry(TrayIds.pauseAll, l.tray_pause_all),
    TrayEntry(TrayIds.resumeAll, l.tray_resume_all),
    const TrayEntry.separator(),
    TrayEntry(TrayIds.quit, l.tray_quit),
  ];

  /// The speed of the daemon, or null while none is connected.
  SpeedData? _speed() {
    try {
      return ref.read(systemSpeedProvider);
    } on StateError {
      return null;
    }
  }

  Future<void> _syncTray() async {
    if (!mounted) return;
    final tray = ref.read(trayProvider);
    final window = ref.read(windowControlProvider);
    final enabled = ref.read(trayEnabledProvider);
    if (!enabled || !tray.supported) {
      if (tray.visible) await tray.hide();
      await window.holdClose(hold: false);
      _shownMenu = null;
      _shownTooltip = null;
      _shownTitle = null;
      return;
    }
    final l = AppLocalizations.of(context);
    final speed = _speed();
    final text = speed == null
        ? null
        : l.status_speed(
            context.speed(speed.down) ?? '0',
            context.speed(speed.up) ?? '0',
          );
    // The speed sits beside the icon on macOS. Other desktops keep it in the
    // tooltip: the title stays null, so a speed change must still be noticed.
    final title = Platform.isMacOS ? text : null;
    final tooltip = text ?? l.tray_tooltip;
    final menu = _menu(l);
    if (!tray.visible) {
      await tray.show(
        iconAsset: trayIconAsset,
        menu: menu,
        tooltip: tooltip,
        title: title,
      );
      await window.holdClose(hold: true);
    } else if (_shownTitle != title ||
        _shownTooltip != tooltip ||
        !listEquals(_shownMenu, menu)) {
      await tray.update(menu: menu, tooltip: tooltip, title: title);
    }
    _shownMenu = menu;
    _shownTitle = title;
    _shownTooltip = tooltip;
  }

  Future<void> _onClose() async {
    final tray = ref.read(trayProvider);
    final window = ref.read(windowControlProvider);
    // Without an icon to bring the window back from, closing quits.
    if (tray.visible) {
      await window.hide();
      return;
    }
    await _releaseDaemon();
    await window.quit();
  }

  void _onTray(String id) {
    final window = ref.read(windowControlProvider);
    switch (id) {
      case TrayIds.show:
        unawaited(window.show());
      case TrayIds.add:
        unawaited(window.show());
        ref.read(addRequestProvider.notifier).request();
      case TrayIds.pauseAll:
        unawaited(_quietly(() => ref.read(taskActionsProvider).pauseAll()));
      case TrayIds.resumeAll:
        unawaited(_quietly(() => ref.read(taskActionsProvider).resumeAll()));
      case TrayIds.quit:
        unawaited(() async {
          await _releaseDaemon();
          await window.quit();
        }());
    }
  }

  Future<void> _quietly(Future<Object?> Function() call) async {
    try {
      await call();
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('tray action failed: $e');
    }
  }

  void _watchTasks(TaskStore store) {
    unawaited(_logs?.cancel());
    _logs = store.logChanged.listen((id) => unawaited(_announce(store, id)));
  }

  Future<void> _announce(TaskStore store, String id) async {
    if (!ref.read(notifyOnFinishProvider)) return;
    final log = store.logOf(id);
    final task = store.tasks[id];
    if (log.isEmpty || task == null) return;
    final last = log.last;
    if (last.kind != TaskLogKind.status) return;
    final l = AppLocalizations.of(context);
    final name = task.name ?? task.resource?.name ?? id;
    final AppNotification note;
    if (last.to == TaskStatus.completed.wire) {
      note = AppNotification(
        id: id.hashCode,
        title: l.notif_completed,
        body: name,
        category: NotifyIds.completed,
        payload: id,
        buttons: [
          NotificationButton(NotifyIds.open, l.notif_open),
          NotificationButton(NotifyIds.folder, l.notif_folder),
        ],
      );
    } else if (last.to == TaskStatus.error.wire) {
      final expired = (last.errorCode ?? '').contains('expired');
      note = AppNotification(
        id: id.hashCode,
        title: expired ? l.notif_expired : l.notif_failed,
        body: last.errorMessage == null ? name : '$name\n${last.errorMessage}',
        category: NotifyIds.failed,
        payload: id,
        buttons: [NotificationButton(NotifyIds.retry, l.notif_retry)],
      );
    } else {
      return;
    }
    try {
      await ref.read(notifierProvider).show(note);
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('notification failed: $e');
    }
  }

  Future<void> _announceLink(LinkRequest r) async {
    if (!mounted || !ref.read(notifyOnFinishProvider)) return;
    final l = AppLocalizations.of(context);
    try {
      await ref
          .read(notifierProvider)
          .show(
            AppNotification(
              id: r.taskId.hashCode,
              title: l.notif_link_wait,
              body: r.name,
              category: NotifyIds.link,
              payload: '${NotifyIds.link}:${r.taskId}',
              buttons: [
                NotificationButton(NotifyIds.openPage, l.notif_open_page),
              ],
            ),
          );
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('notification failed: $e');
    }
  }

  Future<void> _announcePairing(Pairing p) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    try {
      await ref
          .read(notifierProvider)
          .show(
            AppNotification(
              id: p.id.hashCode,
              title: l.pair_notification,
              body: '${p.name} · ${spacedCode(p.code)}',
              category: NotifyIds.pairing,
              payload: '${NotifyIds.pairing}:${p.id}',
            ),
          );
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('notification failed: $e');
    }
  }

  Future<void> _announceQueue(PendingQueueAction action) async {
    if (!mounted || !ref.read(notifyOnFinishProvider)) return;
    final l = AppLocalizations.of(context);
    final name =
        ref.read(taskStoreProvider).queues[action.queueId]?.name ??
        action.queueId;
    try {
      await ref
          .read(notifierProvider)
          .show(
            AppNotification(
              id: Object.hash(NotifyIds.queue, action.queueId),
              title: l.notif_queue,
              body: name,
              category: NotifyIds.queue,
              payload: '${NotifyIds.queue}:${action.queueId}',
            ),
          );
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('notification failed: $e');
    }
  }

  void _onTap(NotificationTap tap) {
    final id = tap.payload;
    if (id == null) return;
    unawaited(_handleTap(id, tap.buttonId));
  }

  Future<void> _handleTap(String id, String? button) async {
    // A queue finishing and an extension asking to pair both need the window,
    // where the answer is.
    if (id.startsWith('${NotifyIds.queue}:') ||
        id.startsWith('${NotifyIds.pairing}:')) {
      await ref.read(windowControlProvider).show();
      return;
    }
    if (id.startsWith('${NotifyIds.link}:')) {
      final taskId = id.substring(NotifyIds.link.length + 1);
      final waiting = ref
          .read(linkRequestsProvider)
          .where((r) => r.taskId == taskId)
          .firstOrNull;
      try {
        if (button == NotifyIds.openPage && waiting != null) {
          await ref.read(urlOpenerProvider).open(waiting.pageUrl);
        } else {
          await ref.read(windowControlProvider).show();
        }
      } on Object catch (e) {
        ref.read(appLoggerProvider).warning('notification action failed: $e');
      }
      return;
    }
    final task = ref.read(taskStoreProvider).tasks[id];
    if (task == null) return;
    final path = taskFilePath(task);
    try {
      switch (button) {
        case NotifyIds.open:
          if (path != null) await ref.read(fileOpenerProvider).open(path);
        case NotifyIds.folder:
          if (path != null) await ref.read(fileOpenerProvider).reveal(path);
        case NotifyIds.retry:
          // Carries on from what was downloaded; a download that must start
          // over is restarted from its menu.
          await ref.read(taskActionsProvider).resume([id]);
        default:
          await ref.read(windowControlProvider).show();
      }
    } on Object catch (e) {
      ref.read(appLoggerProvider).warning('notification action failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
