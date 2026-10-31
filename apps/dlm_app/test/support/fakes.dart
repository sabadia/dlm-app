import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/connection/local_daemon.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';

HealthOutputBody health({int api = 1, int min = 1}) => HealthOutputBody(
  apiVersion: api,
  authenticated: true,
  minClientApi: min,
  status: HealthOutputBodyStatus.ok,
  version: 'test',
);

DlmApi offlineApi() => DlmApi(const DlmEndpoint(baseUrl: 'http://127.0.0.1:1'));

class FakeDaemon implements LocalDaemon {
  FakeDaemon({this.phase = DaemonPhase.running, this.reason, this.delay});

  DaemonPhase phase;
  String? reason;
  Future<void>? delay;
  String tokenValue = 'daemon-token';
  int starts = 0;
  int restarts = 0;
  bool disposed = false;
  bool kept = false;
  final StreamController<DaemonStatus> controller =
      StreamController<DaemonStatus>.broadcast();

  @override
  Future<DaemonStatus> ensureRunning() async {
    starts++;
    await delay;
    return DaemonStatus(
      phase,
      reason: reason,
      info: phase == DaemonPhase.running
          ? const RuntimeInfo(
              pid: 1,
              url: 'http://127.0.0.1:7777',
              version: 'test',
              apiVersion: 1,
            )
          : null,
    );
  }

  @override
  String? token() => tokenValue;

  @override
  Future<void> restart() async => restarts++;

  @override
  Stream<DaemonStatus> get status => controller.stream;

  @override
  Future<void> dispose({bool keepRunning = false}) async {
    kept = keepRunning;
    disposed = true;
    await controller.close();
  }
}

class MemoryVault implements TokenVault {
  final Map<String, String> tokens = {};

  @override
  Future<String?> read(String profileId) async => tokens[profileId];

  @override
  Future<void> write(String profileId, String token) async =>
      tokens[profileId] = token;

  @override
  Future<void> delete(String profileId) async => tokens.remove(profileId);
}

class FakeConnector implements ProfileConnector {
  FakeConnector(this.outcome);

  ConnectOutcome Function(ConnectionProfile, String?, String?) outcome;
  final List<(ConnectionProfile, String?, String?)> calls = [];
  Future<void>? gate;

  @override
  String get userAgent => 'test';

  @override
  Future<ConnectOutcome> connect(
    ConnectionProfile profile, {
    String? token,
    String? localUrl,
    String? localPin,
  }) async {
    calls.add((profile, token, localUrl));
    await gate;
    return outcome(profile, token, localUrl);
  }
}

ProfileStore tempProfileStore(MemoryVault vault) {
  final dir = io.Directory.systemTemp.createTempSync('profiles');
  return ProfileStore(file: io.File('${dir.path}/profiles.json'), vault: vault);
}

// ---- the task layer ----

Task task(
  String id, {
  String status = 'queued',
  int position = 0,
  int size = 1000,
  int downloaded = 0,
  String queueId = 'main',
  String? name,
  Resource? resource,
  TaskError? error,
  String? engine,
  String? dir,
  String priority = 'normal',
  Settings settings = const Settings(),
}) => Task(
  createdAt: DateTime.utc(2026, 10, 29),
  downloaded: downloaded,
  id: id,
  position: position,
  priority: priority,
  queueId: queueId,
  settings: settings,
  size: size,
  source: const Source(
    currentUrl: 'http://example.test/file.bin',
    fingerprint: Fingerprint(size: -1),
  ),
  status: status,
  updatedAt: DateTime.utc(2026, 10, 29),
  name: name ?? 'file-$id',
  resource: resource,
  error: error,
  engine: engine,
  dir: dir,
);

/// A repository over a fixed list: filters by status, queue and text, and
/// pages by cursor, like the daemon.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository(this.tasks);

  List<Task> tasks;
  final List<(TaskQuery, String?, int)> listCalls = [];
  final List<List<String>> paused = [];
  final List<List<String>> resumed = [];
  final List<(List<String>, bool)> deleted = [];
  final List<String> calls = [];

  @override
  Future<TaskPage> list(
    TaskQuery query, {
    String? cursor,
    int limit = 50,
  }) async {
    listCalls.add((query, cursor, limit));
    final all = [
      for (final t in tasks)
        if ((query.statuses.isEmpty || query.statuses.contains(t.statusKind)) &&
            (query.queueId == null || t.queueId == query.queueId) &&
            (query.text == null ||
                (t.name ?? '').toLowerCase().contains(
                  query.text!.toLowerCase(),
                )))
          t,
    ];
    final start = int.tryParse(cursor ?? '0') ?? 0;
    final end = (start + limit).clamp(0, all.length);
    return TaskPage(
      all.sublist(start, end),
      end < all.length ? '$end' : null,
      total: cursor == null ? all.length : null,
    );
  }

  @override
  Future<List<ItemResult>> pause(List<String> ids) async {
    paused.add(ids);
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> resume(List<String> ids) async {
    resumed.add(ids);
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> delete(
    List<String> ids, {
    bool files = false,
  }) async {
    deleted.add((ids, files));
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<Task> get(String id) async => tasks.firstWhere((t) => t.id == id);

  @override
  Future<Task> restart(String id) async {
    calls.add('restart $id');
    return tasks.firstWhere((t) => t.id == id);
  }

  @override
  Future<Task> move(String id, String queueId) => throw UnimplementedError();

  @override
  Future<Task> reorder(String id, int position) async {
    calls.add('reorder:$id:$position');
    return tasks.firstWhere((t) => t.id == id);
  }

  @override
  Future<List<ItemResult>> pauseAll() async {
    calls.add('pauseAll');
    return const [];
  }

  @override
  Future<List<ItemResult>> resumeAll() async {
    calls.add('resumeAll');
    return const [];
  }

  @override
  Future<List<ItemResult>> restartMany(List<String> ids) async {
    calls.add('restartMany:${ids.join(',')}');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> refreshMany(List<String> ids) async {
    calls.add('refreshMany:${ids.join(',')}');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> moveMany(List<String> ids, String queueId) async {
    calls.add('moveMany:${ids.join(',')}:$queueId');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> prioritise(
    List<String> ids,
    UpdateTasksBodyPriority priority,
  ) async {
    calls.add('prioritise:${ids.join(',')}:${priority.json}');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<Task> update(
    String id, {
    String? name,
    String? dir,
    UpdateTaskBodyPriority? priority,
    Map<String, Object?>? settings,
  }) async {
    if (settings != null) calls.add('settings:$id:${jsonEncode(settings)}');
    return tasks.firstWhere((t) => t.id == id);
  }
}

/// A login item that only remembers the last answer.
class FakeLoginItem implements LoginItem {
  FakeLoginItem({this.refuse = false});

  final bool refuse;
  bool enabled = false;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    if (refuse) throw const LoginItemException('refused');
    this.enabled = enabled;
  }

  @override
  Future<bool> startedAtLogin(List<String> args) async => false;
}

/// The daemon's login item, recording the verbs it was asked.
class FakeDaemonService extends DaemonService {
  FakeDaemonService() : super(executable: '/bin/dlm');

  final List<String> calls = [];
  bool installed = false;

  DaemonServiceStatus _status() => DaemonServiceStatus(
    kind: 'launchd',
    installed: installed,
    active: installed,
  );

  @override
  Future<DaemonServiceStatus> status() async {
    calls.add('status');
    return _status();
  }

  @override
  Future<DaemonServiceStatus> install() async {
    calls.add('install');
    installed = true;
    return _status();
  }

  @override
  Future<DaemonServiceStatus> uninstall() async {
    calls.add('uninstall');
    installed = false;
    return _status();
  }
}

/// A preference that lives only in memory. A test that changes a real one
/// writes the preferences file in the background, and on Windows that file is
/// still open when the test's folder is deleted.
class MemoryPref<T> extends PrefNotifier<T> {
  /// Creates the preference with [initial].
  MemoryPref(super.pref, this.initial);

  /// The value it starts with.
  final T initial;

  @override
  T build() => initial;

  @override
  Future<void> set(T value) async => state = value;
}
