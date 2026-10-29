import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

/// Queues in memory that record the settings they are given.
class _Queues extends QueuesController {
  final List<Settings> replaced = [];

  @override
  Future<List<Queue>> build() async => [
    Queue(
      createdAt: DateTime.utc(2026),
      id: 'q1',
      isDefault: true,
      name: 'Default',
      position: 0,
      settings: const Settings(maxConnections: 4),
      state: 'running',
      updatedAt: DateTime.utc(2026),
    ),
  ];

  @override
  Future<Queue> replaceSettings(String id, Settings settings) async {
    replaced.add(settings);
    return (await build()).single;
  }
}

/// Effective settings that say the queue sets maxConnections and the rest is
/// global.
class _Repo implements SettingsRepository {
  @override
  Future<EffectiveSettings> effectiveForQueue(String id) async =>
      EffectiveSettings.of(
        const Effective(
          settings: Settings(maxConnections: 4, speedLimit: 100),
          sources: {'maxConnections': 'queue', 'speedLimit': 'global'},
        ),
      );

  @override
  Future<EffectiveSettings> effectiveForTask(String id) async =>
      EffectiveSettings.of(
        const Effective(
          settings: Settings(maxConnections: 2),
          sources: {'maxConnections': 'task'},
        ),
      );

  @override
  Future<GlobalSettings> load() => throw UnimplementedError();

  @override
  Future<GlobalSettings> patch(
    Map<String, Object?> mergePatch, {
    String? etag,
  }) => throw UnimplementedError();

  @override
  Future<Schema> schema() => throw UnimplementedError();
}

void main() {
  late ProviderContainer container;
  late FakeTaskRepository tasks;
  late _Queues queues;
  setUp(() {
    tasks = FakeTaskRepository();
    queues = _Queues();
    container = ProviderContainer.test(
      overrides: [
        queuesProvider.overrideWith(() => queues),
        settingsRepositoryProvider.overrideWithValue(_Repo()),
        taskRepositoryProvider.overrideWithValue(tasks),
      ],
    );
  });

  test(
    'a queue snapshot shows its overrides and where values come from',
    () async {
      final s = await container.read(
        settingsSnapshotProvider(const SettingsTarget.queue('q1')).future,
      );
      expect(s.level, SettingLevel.queue);
      expect(s.overrides, {'maxConnections': 4});
      final d = SettingsDraft(s);
      expect(d.isOverridden('maxConnections'), isTrue);
      expect(d.levelOf('maxConnections'), SettingLevel.queue);
      expect(d.levelOf('speedLimit'), SettingLevel.global);
    },
  );

  test('saving a queue replaces its overrides with the edited ones', () async {
    const target = SettingsTarget.queue('q1');
    final s = await container.read(settingsSnapshotProvider(target).future);
    final d = SettingsDraft(s)
      ..set('speedLimit', 500)
      ..reset('maxConnections');
    await container.read(settingsSaverProvider)(target, d);
    expect(queues.replaced.single.speedLimit, 500);
    expect(queues.replaced.single.maxConnections, isNull);
  });

  test(
    'a task snapshot is built from the task and its effective settings',
    () async {
      final t = task('a');
      tasks.tasks.add(t);
      container.read(taskStoreProvider).tasks.put('a', t);
      final s = await container.read(
        settingsSnapshotProvider(const SettingsTarget.task('a')).future,
      );
      expect(s.level, SettingLevel.task);
      expect(
        SettingsDraft(s).levelOf('maxConnections'),
        SettingLevel.defaults,
        reason: 'not overridden by the task itself, so it falls back',
      );
    },
  );

  test('saving nothing sends nothing', () async {
    const target = SettingsTarget.queue('q1');
    final s = await container.read(settingsSnapshotProvider(target).future);
    await container.read(settingsSaverProvider)(target, SettingsDraft(s));
    expect(queues.replaced, isEmpty);
  });

  test('targets compare by level and id', () {
    expect(const SettingsTarget.queue('a'), const SettingsTarget.queue('a'));
    expect(
      const SettingsTarget.queue('a') == const SettingsTarget.task('a'),
      isFalse,
    );
    expect(const SettingsTarget.global().id, isNull);
  });
}
