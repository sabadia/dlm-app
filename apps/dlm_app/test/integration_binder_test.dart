import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/platform/file_opener.dart';
import 'package:dlm_app/src/platform/integration_binder.dart';
import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

class RecordingTray implements TrayController {
  RecordingTray({this.supported = true});

  @override
  final bool supported;

  @override
  bool visible = false;

  List<TrayEntry> menu = const [];
  String? title;
  String? tooltip;

  final _selections = StreamController<String>.broadcast();

  @override
  Stream<String> get selections => _selections.stream;

  void choose(String id) => _selections.add(id);

  @override
  Future<void> show({
    required String iconAsset,
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  }) async {
    visible = true;
    this.menu = menu;
    this.tooltip = tooltip;
    this.title = title;
  }

  @override
  Future<void> update({
    required List<TrayEntry> menu,
    String? tooltip,
    String? title,
  }) async {
    this.menu = menu;
    this.tooltip = tooltip;
    this.title = title;
  }

  @override
  Future<void> hide() async => visible = false;
}

class RecordingWindow implements WindowControl {
  bool holding = false;
  int shows = 0;
  int hides = 0;
  int quits = 0;

  final _requests = StreamController<void>.broadcast();

  @override
  Stream<void> get closeRequests => _requests.stream;

  void requestClose() => _requests.add(null);

  @override
  Future<void> holdClose({required bool hold}) async => holding = hold;

  @override
  Future<void> show() async => shows++;

  @override
  Future<void> hide() async => hides++;

  @override
  Future<void> quit() async => quits++;
}

class RecordingNotifier implements DesktopNotifier {
  final shown = <AppNotification>[];
  Map<String, List<NotificationButton>> categories = const {};

  final _taps = StreamController<NotificationTap>.broadcast();

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  void tap(NotificationTap tap) => _taps.add(tap);

  @override
  Future<bool> init({
    Map<String, List<NotificationButton>> categories = const {},
  }) async {
    this.categories = categories;
    return true;
  }

  @override
  Future<void> show(AppNotification notification) async {
    shown.add(notification);
  }
}

class RecordingOpener implements FileOpener {
  final opened = <String>[];
  final revealed = <String>[];

  @override
  Future<void> open(String path) async => opened.add(path);

  @override
  Future<void> reveal(String path) async => revealed.add(path);
}

StreamEvent statusEvent(
  String id,
  String from,
  String to, {
  TaskError? error,
}) => StreamEvent.fromJson({
  'id': 1,
  'type': 'task.status',
  'taskId': id,
  'time': '2026-10-30T10:00:00Z',
  'data': {
    'from': from,
    'to': to,
    if (error != null) 'error': jsonDecode(jsonEncode(error)),
  },
});

StreamEvent taskEvent(String type, Task t) => StreamEvent.fromJson({
  'id': 3,
  'type': type,
  'taskId': t.id,
  'time': '2026-10-30T10:00:02Z',
  'data': jsonDecode(jsonEncode(t)),
});

void main() {
  appTest('the tray shows speed, and closing hides while the icon is up', (
    tester,
  ) async {
    final tray = RecordingTray();
    final window = RecordingWindow();
    final h = await pumpApp(
      tester,
      overrides: [
        trayProvider.overrideWithValue(tray),
        windowControlProvider.overrideWithValue(window),
        notifierProvider.overrideWithValue(RecordingNotifier()),
      ],
    );
    expect(tray.visible, isTrue);
    expect(window.holding, isTrue);
    expect(tray.menu.map((e) => e.id), [
      'show',
      '',
      'add',
      'pause-all',
      'resume-all',
      '',
      'quit',
    ]);

    h.container
        .read(taskStoreProvider)
        .apply(
          StreamEvent.fromJson({
            'id': 4,
            'type': 'system.speed',
            'time': '2026-10-30T10:00:03Z',
            'data': {'active': 1, 'down': 2 * 1048576, 'queued': 0, 'up': 0},
          }),
        );
    await settle(tester);
    expect(tray.tooltip, contains('2.00 MiB/s'));
    expect(tray.title, Platform.isMacOS ? tray.tooltip : isNull);

    window.requestClose();
    await settle(tester);
    expect(window.hides, 1);
    expect(window.quits, 0);

    tray.choose(TrayIds.pauseAll);
    await settle(tester);
    expect(h.tasks.calls, contains('pauseAll'));

    tray.choose(TrayIds.add);
    await settle(tester);
    expect(find.text('Add downloads'), findsWidgets);

    tray.choose(TrayIds.quit);
    await settle(tester);
    expect(window.quits, 1);
  });

  appTest('without a tray, closing the window quits', (tester) async {
    final tray = RecordingTray(supported: false);
    final window = RecordingWindow();
    await pumpApp(
      tester,
      overrides: [
        trayProvider.overrideWithValue(tray),
        windowControlProvider.overrideWithValue(window),
        notifierProvider.overrideWithValue(RecordingNotifier()),
      ],
    );
    expect(tray.visible, isFalse);
    expect(window.holding, isFalse);
    window.requestClose();
    await settle(tester);
    expect(window.quits, 1);
    expect(window.hides, 0);
  });

  appTest('a finished or failed download is announced, and its buttons act', (
    tester,
  ) async {
    final notes = RecordingNotifier();
    final files = RecordingOpener();
    final item = task('a', status: 'running', dir: '/tmp/dl', name: 'a.bin');
    final h = await pumpApp(
      tester,
      tasks: [item],
      overrides: [
        trayProvider.overrideWithValue(RecordingTray(supported: false)),
        windowControlProvider.overrideWithValue(RecordingWindow()),
        notifierProvider.overrideWithValue(notes),
        fileOpenerProvider.overrideWithValue(files),
      ],
    );
    expect(notes.categories.keys, containsAll(['completed', 'failed']));
    final store = h.container.read(taskStoreProvider)
      ..apply(taskEvent('task.created', item))
      ..apply(statusEvent('a', 'running', 'completed'));
    await settle(tester);
    expect(notes.shown.single.title, 'Download finished');
    expect(notes.shown.single.body, 'a.bin');

    notes.tap(const NotificationTap(payload: 'a', buttonId: NotifyIds.open));
    await settle(tester);
    expect(files.opened, ['/tmp/dl${Platform.pathSeparator}a.bin']);

    store.apply(
      statusEvent(
        'a',
        'completed',
        'error',
        error: TaskError(
          at: DateTime.utc(2026, 10, 30),
          code: 'link.expired',
          message: 'gone',
          retryable: false,
        ),
      ),
    );
    await settle(tester);
    expect(notes.shown.last.title, 'Link expired');

    notes.tap(const NotificationTap(payload: 'a', buttonId: NotifyIds.retry));
    await settle(tester);
    expect(h.tasks.calls, contains('restart a'));

    // `set` writes the preferences file. Awaiting that I/O never finishes
    // inside the test's fake clock; the value itself is stored at once.
    unawaited(h.container.read(notifyOnFinishProvider.notifier).set(false));
    store.apply(statusEvent('a', 'error', 'completed'));
    await settle(tester);
    expect(
      notes.shown.where((n) => n.title == 'Download finished'),
      hasLength(1),
    );
  });

  appTest('a finished queue is announced', (tester) async {
    final notes = RecordingNotifier();
    final h = await pumpApp(
      tester,
      liveSync: true,
      queues: [queue('night', 'Night')],
      overrides: [
        trayProvider.overrideWithValue(RecordingTray(supported: false)),
        windowControlProvider.overrideWithValue(RecordingWindow()),
        notifierProvider.overrideWithValue(notes),
      ],
    );
    h.events.add(
      SseData(
        SseMessage(
          id: 'q1',
          event: 'queue.completed',
          data: jsonEncode({
            'id': 1,
            'type': 'queue.completed',
            'queueId': 'night',
            'time': '2026-10-29T10:00:00Z',
            'data': {
              'action': 'stop',
              'completedTasks': 2,
              'executeAt': '2026-10-29T10:01:00Z',
            },
          }),
        ),
      ),
    );
    await settle(tester);
    expect(notes.shown.single.title, 'Queue finished');
    expect(notes.shown.single.body, 'night');
  });
}
