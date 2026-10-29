import 'dart:async';
import 'dart:convert';
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
/// The speed limits in memory; records the turbo switches.
class FakeLimits extends LimitsController {
  FakeLimits(this.view);

  LimitsView view;
  final List<String> calls = [];

  @override
  Future<LimitsView> build() async => view;

  @override
  Future<void> turbo(int minutes) async {
    calls.add('turbo $minutes');
    view = LimitsView(
      global: view.global,
      queues: const [],
      override: SpeedOverride(speedLimit: 0, until: DateTime.utc(2030)),
    );
    state = AsyncData(view);
  }

  @override
  Future<void> endTurbo() async {
    calls.add('end');
    view = LimitsView(global: view.global, queues: const []);
    state = AsyncData(view);
  }
}

/// The categories in memory; records what is asked of them.
class FakeCategories extends CategoriesController {
  FakeCategories(this.categories);

  List<Category> categories;
  final List<String> calls = [];

  @override
  Future<List<Category>> build() async => categories;

  @override
  Future<Category> create(CreateCategoryBody body) async {
    calls.add('create ${body.name} ${body.dir} ${body.extensions}');
    final c = Category(
      dir: body.dir,
      id: 'new${categories.length}',
      name: body.name,
      position: categories.length,
      extensions: body.extensions,
      mimeTypes: body.mimeTypes,
    );
    categories = [...categories, c];
    state = AsyncData(categories);
    return c;
  }

  @override
  Future<Category> edit(String id, UpdateCategoryBody body) async {
    calls.add('edit $id ${body.name} ${body.dir} ${body.extensions}');
    final old = categories.firstWhere((c) => c.id == id);
    final c = Category(
      dir: body.dir ?? old.dir,
      id: id,
      name: body.name ?? old.name,
      position: old.position,
      extensions: body.extensions ?? old.extensions,
      mimeTypes: body.mimeTypes ?? old.mimeTypes,
    );
    categories = [
      for (final o in categories)
        if (o.id == id) c else o,
    ];
    state = AsyncData(categories);
    return c;
  }

  @override
  Future<void> remove(String id) async {
    calls.add('remove $id');
    categories = [
      for (final c in categories)
        if (c.id != id) c,
    ];
    state = AsyncData(categories);
  }

  @override
  Future<void> moveTo(String id, int position) async {
    calls.add('move $id $position');
    final list = [...categories];
    final at = list.indexWhere((c) => c.id == id);
    final item = list.removeAt(at);
    list.insert(position, item);
    categories = [
      for (final (i, c) in list.indexed)
        Category(
          dir: c.dir,
          id: c.id,
          name: c.name,
          position: i,
          extensions: c.extensions,
          mimeTypes: c.mimeTypes,
        ),
    ];
    state = AsyncData(categories);
  }

  @override
  Future<Category?> match({String? name, String? mimeType}) async {
    calls.add('match $name $mimeType');
    final ext = (name ?? '').contains('.') ? name!.split('.').last : '';
    for (final c in categories) {
      if ((c.extensions ?? const []).contains(ext)) return c;
    }
    return null;
  }
}

/// The site logins in memory.
class FakeCredentials extends CredentialsController {
  FakeCredentials(this.logins);

  List<Credential> logins;
  final List<String> calls = [];

  @override
  Future<List<Credential>> build() async => logins;

  @override
  Future<Credential> create(CreateCredentialBody body) async {
    calls.add(
      'create ${body.host} ${body.username} ${body.password} ${body.scheme?.json}',
    );
    final c = Credential(
      createdAt: DateTime.utc(2026),
      host: body.host,
      id: 'n${logins.length}',
      scheme: body.scheme?.json ?? 'auto',
      updatedAt: DateTime.utc(2026),
      username: body.username,
    );
    logins = [...logins, c];
    state = AsyncData(logins);
    return c;
  }

  @override
  Future<Credential> edit(String id, UpdateCredentialBody body) async {
    calls.add(
      'edit $id ${body.host} ${body.username} ${body.password} ${body.scheme?.json}',
    );
    return logins.firstWhere((c) => c.id == id);
  }

  @override
  Future<void> remove(String id) async {
    calls.add('remove $id');
    logins = [
      for (final c in logins)
        if (c.id != id) c,
    ];
    state = AsyncData(logins);
  }
}

/// The cookie store in memory; values only leave through [export].
class FakeCookies extends CookiesController {
  FakeCookies(this.cookies);

  List<CookieInfo> cookies;
  final List<String> calls = [];

  @override
  Future<List<CookieInfo>> build() async => cookies;

  @override
  Future<void> removeDomain(String domain) async {
    calls.add('removeDomain $domain');
    cookies = [
      for (final c in cookies)
        if (c.domain != domain) c,
    ];
    state = AsyncData(cookies);
  }

  @override
  Future<void> removeCookie(String id) async {
    calls.add('removeCookie $id');
    cookies = [
      for (final c in cookies)
        if (c.id != id) c,
    ];
    state = AsyncData(cookies);
  }

  @override
  Future<ImportCookiesResult> import(ImportCookiesBody body) async {
    calls.add('import ${body.format?.json} ${body.data.length}');
    return const ImportCookiesResult(
      imported: 2,
      skipped: 1,
      errors: ['line 3: bad domain'],
    );
  }

  @override
  Future<ExportCookiesResult> export({
    Format format = Format.netscape,
    String? domain,
  }) async {
    calls.add('export ${format.json} $domain');
    return ExportCookiesResult(
      count: 1,
      data: 'SECRET-DATA',
      format: format == Format.valueJson
          ? ExportCookiesResultFormat.valueJson
          : ExportCookiesResultFormat.netscape,
    );
  }
}

/// The webhooks in memory.
class FakeWebhooks extends WebhooksController {
  FakeWebhooks(
    this.hooks, {
    this.deliveryList = const [],
    this.failTest = false,
  });

  List<Webhook> hooks;
  final List<Delivery> deliveryList;
  final bool failTest;
  final List<String> calls = [];

  @override
  Future<List<Webhook>> build() async => hooks;

  @override
  Future<Webhook> create(CreateWebhookBody body) async {
    calls.add(
      'create ${body.url} ${body.events} ${body.secret} ${body.disabled}',
    );
    final h = Webhook(
      createdAt: DateTime.utc(2026),
      enabled: body.disabled != true,
      events: body.events,
      hasSecret: body.secret != null,
      id: 'n${hooks.length}',
      updatedAt: DateTime.utc(2026),
      url: body.url,
    );
    hooks = [...hooks, h];
    state = AsyncData(hooks);
    return h;
  }

  @override
  Future<Webhook> edit(String id, UpdateWebhookBody body) async {
    calls.add(
      'edit $id ${body.url} ${body.events} ${body.secret} ${body.enabled}',
    );
    final old = hooks.firstWhere((h) => h.id == id);
    final h = Webhook(
      createdAt: old.createdAt,
      enabled: body.enabled ?? old.enabled,
      events: body.events ?? old.events,
      hasSecret: old.hasSecret,
      id: id,
      updatedAt: old.updatedAt,
      url: body.url ?? old.url,
    );
    hooks = [
      for (final o in hooks)
        if (o.id == id) h else o,
    ];
    state = AsyncData(hooks);
    return h;
  }

  @override
  Future<void> remove(String id) async {
    calls.add('remove $id');
    hooks = [
      for (final h in hooks)
        if (h.id != id) h,
    ];
    state = AsyncData(hooks);
  }

  @override
  Future<void> test(String id) async {
    calls.add('test $id');
    if (failTest) {
      throw const ApiProblem(status: 502, code: 'webhook.delivery_failed');
    }
  }

  @override
  Future<List<Delivery>> deliveries(String id) async {
    calls.add('deliveries $id');
    return deliveryList;
  }
}

/// The plugins in memory.
class FakePlugins extends PluginsController {
  FakePlugins(this.plugins, {this.records = const []});

  List<Plugin> plugins;
  final List<Record> records;
  final List<String> calls = [];

  @override
  Future<List<Plugin>> build() async => plugins;

  @override
  Future<Plugin> install(InstallPluginBody body) async {
    calls.add(
      'install ${body.source} ${body.ref} ${body.replace} ${body.disabled}',
    );
    final p = Plugin(
      enabled: body.disabled != true,
      installedAt: DateTime.utc(2026),
      name: 'fresh',
      source: body.source,
      updatedAt: DateTime.utc(2026),
      version: '0.1.0',
      title: 'Fresh plugin',
      description: 'Does things',
      hooks: const ['download.completed'],
      net: const ['api.example.com'],
    );
    plugins = [...plugins, p];
    state = AsyncData(plugins);
    return p;
  }

  @override
  Future<Plugin> setEnabled(String name, {required bool enabled}) async {
    calls.add('enabled $name $enabled');
    final old = plugins.firstWhere((p) => p.name == name);
    final p = Plugin(
      enabled: enabled,
      installedAt: old.installedAt,
      name: old.name,
      source: old.source,
      updatedAt: old.updatedAt,
      version: old.version,
      title: old.title,
      description: old.description,
      hooks: old.hooks,
      net: old.net,
      error: old.error,
    );
    plugins = [
      for (final o in plugins)
        if (o.name == name) p else o,
    ];
    state = AsyncData(plugins);
    return p;
  }

  @override
  Future<void> remove(String name) async {
    calls.add('remove $name');
    plugins = [
      for (final p in plugins)
        if (p.name != name) p,
    ];
    state = AsyncData(plugins);
  }

  @override
  Future<LogList> logs(String name, {Level? level, String? q}) async {
    calls.add('logs $name ${level?.json} $q');
    return LogList(
      bootId: 'b',
      hasMore: false,
      lastId: records.isEmpty ? 0 : records.last.id,
      records: records,
    );
  }
}

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
  Map<String, Map<String, int>> counts = const {},
  LimitsView? limits,
  List<Category> categories = const [],
  List<Credential> logins = const [],
  List<CookieInfo> cookies = const [],
  List<Override> overrides = const [],
  PreferencesStore? preferences,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Real file I/O never completes inside the test's fake-async zone.
  final PreferencesStore prefs;
  if (preferences != null) {
    prefs = preferences;
  } else {
    final dir = io.Directory.systemTemp.createTempSync('dlm_app_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    prefs = (await tester.runAsync(
      () => PreferencesStore.open(io.File('${dir.path}/prefs.json')),
    ))!;
  }
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
      queueCountsSourceProvider.overrideWithValue(() async => counts),
      categoriesProvider.overrideWith(() => FakeCategories(categories)),
      credentialsProvider.overrideWith(() => FakeCredentials(logins)),
      cookiesProvider.overrideWith(() => FakeCookies(cookies)),
      limitsProvider.overrideWith(
        () => FakeLimits(
          limits ??
              const LimitsView(
                global: ScopeLimits(configuredSpeedLimit: 0, speedLimit: 0),
                queues: [],
              ),
        ),
      ),
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
SystemInfo systemInfo(List<ToolStatus> tools, {int minClientApi = 1}) =>
    SystemInfo(
      address: '127.0.0.1:1',
      apiVersion: 1,
      arch: 'arm64',
      databaseBytes: 0,
      engines: const ['http'],
      fsRoots: const [],
      goVersion: 'go1.26',
      local: true,
      minClientApi: minClientApi,
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

/// Global settings in memory that record the patches sent to them. A patch
/// is applied as an RFC 7396 merge patch; [failWith] makes the next one fail.
class FakeGlobalSettings extends GlobalSettingsController {
  FakeGlobalSettings({
    String? downloadDir,
    Settings? stored,
    Settings? defaults,
    this.failWith,
  }) : _stored =
           stored ??
           Settings(downloadDir: downloadDir ?? '/Users/test/Downloads'),
       _defaults =
           defaults ?? const Settings(downloadDir: '/Users/test/Downloads');

  Settings _stored;
  final Settings _defaults;
  ApiProblem? failWith;
  final List<Map<String, Object?>> patches = [];

  GlobalSettings get _value =>
      GlobalSettings(settings: _stored, defaults: _defaults);

  @override
  Future<GlobalSettings> build() async => _value;

  @override
  Future<void> patch(Map<String, Object?> mergePatch) async {
    patches.add(mergePatch);
    final problem = failWith;
    if (problem != null) {
      failWith = null;
      throw problem;
    }
    final json =
        jsonDecode(jsonEncode(_stored.toJson())) as Map<String, Object?>;
    _stored = Settings.fromJson(applyMergePatch(json, mergePatch));
    state = AsyncData(_value);
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
