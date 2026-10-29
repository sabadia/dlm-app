import 'dart:async';
import 'dart:io' as io;

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/connection/connection_controller.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/queues/queue_countdown.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Queue queue(String id, String name, {int position = 0}) => Queue(
  createdAt: DateTime.utc(2026, 10, 29),
  id: id,
  isDefault: id == 'main',
  name: name,
  position: position,
  settings: const Settings(),
  state: 'stopped',
  updatedAt: DateTime.utc(2026, 10, 29),
);

/// Queues held in memory: the commands change the list the way the daemon's
/// answers would and are recorded in [calls].
class FakeQueues extends QueuesController {
  FakeQueues(this.queues);

  List<Queue> queues;
  final List<String> calls = [];
  Settings? savedSettings;

  @override
  Future<List<Queue>> build() async => queues;

  void _set(List<Queue> next) {
    queues = next;
    state = AsyncData(next);
  }

  Queue _replace(String id, Queue Function(Queue) change) {
    final updated = change(queues.firstWhere((q) => q.id == id));
    _set([
      for (final q in queues)
        if (q.id == id) updated else q,
    ]);
    return updated;
  }

  Queue _with(Queue q, {String? name, String? state, Settings? settings}) =>
      Queue(
        createdAt: q.createdAt,
        id: q.id,
        isDefault: q.isDefault,
        name: name ?? q.name,
        position: q.position,
        settings: settings ?? q.settings,
        state: state ?? q.state,
        updatedAt: q.updatedAt,
      );

  @override
  Future<Queue> create(CreateQueueBody body) async {
    calls.add('create ${body.name}');
    final created = queue(
      'q${queues.length + 1}',
      body.name,
      position: queues.length,
    );
    _set([...queues, created]);
    return created;
  }

  @override
  Future<Queue> edit(String id, UpdateQueueBody body) async {
    calls.add('edit $id ${body.name}');
    return _replace(id, (q) => _with(q, name: body.name));
  }

  @override
  Future<Queue> start(String id) async {
    calls.add('start $id');
    return _replace(id, (q) => _with(q, state: 'running'));
  }

  @override
  Future<Queue> stop(String id) async {
    calls.add('stop $id');
    return _replace(id, (q) => _with(q, state: 'stopped'));
  }

  @override
  Future<Queue> reorder(String id, int position) async {
    calls.add('reorder $id $position');
    return queues.firstWhere((q) => q.id == id);
  }

  @override
  Future<Queue> replaceSettings(String id, Settings settings) async {
    calls.add('settings $id');
    savedSettings = settings;
    return _replace(id, (q) => _with(q, settings: settings));
  }

  @override
  Future<void> remove(String id, {String? moveTasksTo}) async {
    calls.add('remove $id to $moveTasksTo');
    _set([
      for (final q in queues)
        if (q.id != id) q,
    ]);
  }
}

class ReadyConnection extends ConnectionController {
  ReadyConnection(this.session);

  final DlmSession session;

  @override
  ConnectionStatus build() =>
      Ready(const ConnectionProfile.local(), session, health());
}

/// The container of the app under test, so [appTest] can dispose it inside
/// the test body.
ProviderContainer? _current;
EventHub? _hub;

/// A sync engine that never connects: most tests do not need live events and
/// a started hub leaves timers behind.
class IdleSync extends SyncEngine {
  IdleSync({required super.hub, required super.store});

  @override
  void start() {}

  @override
  Future<void> stop() async {}
}

class AppHarness {
  AppHarness(this.tasks, this.container, this.events);

  final FakeTaskRepository tasks;
  final ProviderContainer container;
  final StreamController<SseFrame> events;
}

/// Pumps the whole app on fakes: a repository over [tasks], the given
/// [queues], an event stream the test controls, and a temporary preferences
/// file. Returns handles to drive and inspect it.
Future<AppHarness> pumpApp(
  WidgetTester tester, {
  List<Task> tasks = const [],
  List<Queue> queues = const [],
  Size size = const Size(1400, 900),
  bool liveSync = false,
  bool onboarded = true,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final dir = io.Directory.systemTemp.createTempSync('dlm_app_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  // Real file I/O never completes inside the test's fake-async zone.
  final prefs = (await tester.runAsync(
    () => PreferencesStore.open(io.File('${dir.path}/prefs.json')),
  ))!;
  if (onboarded) {
    await tester.runAsync(() => prefs.set(UiPrefs.onboardingDone, true));
  }
  // Not disposed: closing its stream inside the fake-async zone never
  // completes, and the temporary file goes away with its directory.

  final events = StreamController<SseFrame>();
  // close() of a stream nobody listens to never completes: do not wait.
  addTearDown(() => unawaited(events.close()));
  final session = DlmSession(
    api: offlineApi(),
    hub: EventHub(
      open: (_, _) => events.stream,
      flushInterval: const Duration(milliseconds: 1),
    ),
  );
  final repo = FakeTaskRepository(tasks);

  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      sessionProvider.overrideWithValue(session),
      connectionProvider.overrideWith(() => ReadyConnection(session)),
      taskRepositoryProvider.overrideWithValue(repo),
      if (!liveSync)
        syncEngineProvider.overrideWith(
          (ref) => IdleSync(
            hub: ref.watch(sessionProvider).hub,
            store: ref.watch(taskStoreProvider),
          ),
        ),
      queuesProvider.overrideWith(() => FakeQueues(queues)),
      clockProvider.overrideWithValue(tester.binding.clock.now),
      ...overrides,
    ],
  );
  _current = container;
  _hub = session.hub;

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const DlmApp()),
  );
  await tester.pump();
  await settle(tester);
  return AppHarness(repo, container, events);
}

/// A widget test that pumps the app on fakes and, after the body, tears the
/// app down inside the test (timers of the session and the sync engine must be
/// gone before the framework checks for pending timers).
void appTest(
  String name,
  Future<void> Function(WidgetTester tester) body, {
  bool skip = false,
}) {
  testWidgets(name, skip: skip, (tester) async {
    try {
      await body(tester);
    } finally {
      await tester.pumpWidget(const SizedBox());
      _current?.dispose();
      _current = null;
      // The sync engine stops the hub asynchronously; its timers must be
      // gone before the framework looks for pending ones.
      unawaited(_hub?.stop());
      _hub = null;
      // Let any leftover (fake) timer, such as the hub's 45 s watchdog,
      // expire now that nothing is running.
      await tester.pump(const Duration(seconds: 120));
    }
  });
}

/// Lets routes build, lists load and debounces fire: a page that was just
/// created starts loading after its first frame, so several frames are needed.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// What a daemon reports about itself, with the given tools.
SystemInfo systemInfo(List<ToolStatus> tools) => SystemInfo(
  address: '127.0.0.1:1',
  apiVersion: 1,
  arch: 'arm64',
  databaseBytes: 0,
  engines: const ['http'],
  fsRoots: const [],
  goVersion: 'go1.26',
  local: true,
  minClientApi: 1,
  os: 'darwin',
  paths: const SystemPaths(
    cache: '/c',
    config: '/cfg',
    data: '/d',
    database: '/db',
    downloads: '/dl',
    log: '/l',
  ),
  pid: 1,
  startedAt: DateTime.utc(2026, 10, 29),
  tls: false,
  tools: tools,
  uptimeSeconds: 1,
  version: '0.2.1',
);

/// Global settings in memory that record the patches sent to them.
class FakeGlobalSettings extends GlobalSettingsController {
  FakeGlobalSettings({String? downloadDir})
    : _dir = downloadDir ?? '/Users/test/Downloads';

  String _dir;
  final List<Map<String, Object?>> patches = [];

  @override
  Future<GlobalSettings> build() async => GlobalSettings(
    settings: Settings(downloadDir: _dir),
    defaults: const Settings(downloadDir: '/Users/test/Downloads'),
  );

  @override
  Future<void> patch(Map<String, Object?> mergePatch) async {
    patches.add(mergePatch);
    _dir = mergePatch['downloadDir']! as String;
    state = AsyncData(
      GlobalSettings(
        settings: Settings(downloadDir: _dir),
        defaults: const Settings(downloadDir: '/Users/test/Downloads'),
      ),
    );
  }
}

/// A link-renewal service in memory that records what is asked of it.
class FakeRefresh implements RefreshRepository {
  FakeRefresh(this.tasks, [this.attempts = const []]);

  final FakeTaskRepository tasks;
  List<RefreshAttempt> attempts;
  final List<String> calls = [];

  Task _task(String id) => tasks.tasks.firstWhere((t) => t.id == id);

  @override
  Future<Task> refresh(String id) async {
    calls.add('refresh $id');
    return _task(id);
  }

  @override
  Future<Task> awaitLink(String id) async {
    calls.add('await $id');
    return _task(id);
  }

  @override
  Future<Task> setLink(
    String id,
    String url, {
    UpdateTaskSourceBodyOnMismatch? onMismatch,
  }) async {
    calls.add('link $id $url ${onMismatch?.json}');
    return _task(id);
  }

  @override
  Future<List<RefreshAttempt>> history(String id) async => attempts;
}
