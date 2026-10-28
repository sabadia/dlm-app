import 'package:dlm_api/dlm_api.dart';

/// The global settings layer as last read, with its version.
class GlobalSettings {
  /// Creates the value.
  const GlobalSettings({
    required this.settings,
    required this.defaults,
    this.etag,
  });

  /// The stored global layer; unset fields inherit [defaults].
  final Settings settings;

  /// The built-in lowest layer.
  final Settings defaults;

  /// Version of [settings]; sent back as `If-Match` so an update fails instead
  /// of overwriting somebody else's change.
  final String? etag;
}

/// Where a setting's effective value comes from.
enum SettingLevel {
  /// Built in.
  defaults,

  /// The global layer.
  global,

  /// A queue's override.
  queue,

  /// A task's override.
  task;

  /// Parses the daemon's name for a level; unknown names count as [defaults].
  static SettingLevel parse(String? value) => SettingLevel.values.firstWhere(
    (l) => l.name == value || (l == defaults && value == 'default'),
    orElse: () => defaults,
  );
}

/// Effective settings of a queue or task with the origin of every value.
class EffectiveSettings {
  /// Creates the value.
  const EffectiveSettings(this.settings, this._sources);

  /// Decodes the daemon's answer.
  factory EffectiveSettings.of(Effective e) => EffectiveSettings(e.settings, {
    for (final s in e.sources.entries) s.key: SettingLevel.parse(s.value),
  });

  /// The resolved values.
  final Settings settings;

  final Map<String, SettingLevel> _sources;

  /// Where the value at [path] (`retry.maxAttempts`) comes from; fields that
  /// are unset everywhere report [SettingLevel.defaults].
  SettingLevel levelOf(String path) => _sources[path] ?? SettingLevel.defaults;

  /// Whether a layer above the defaults sets [path].
  bool isOverridden(String path) => levelOf(path) != SettingLevel.defaults;
}

/// What the app asks of the daemon about settings.
abstract interface class SettingsRepository {
  /// The global layer, the defaults and the version of the global layer.
  Future<GlobalSettings> load();

  /// Applies an RFC 7396 merge patch (`null` unsets a field) to the global
  /// layer; fails with `ApiProblem` 412 when [etag] is stale.
  Future<GlobalSettings> patch(Map<String, Object?> mergePatch, {String? etag});

  /// The description of every settings field.
  Future<Schema> schema();

  /// Effective settings of a task.
  Future<EffectiveSettings> effectiveForTask(String id);

  /// Effective settings of a queue.
  Future<EffectiveSettings> effectiveForQueue(String id);
}

/// [SettingsRepository] over the generated client.
class ApiSettingsRepository implements SettingsRepository {
  /// Creates the repository.
  ApiSettingsRepository(this._api);

  final DlmApi _api;

  SettingsClient get _settings => _api.rest.settings;

  @override
  Future<GlobalSettings> load() => guard(() async {
    final settings = await _settings.getSettings();
    final etag = _api.etagFor('/v1/settings');
    final defaults = await _settings.getDefaultSettings();
    return GlobalSettings(settings: settings, defaults: defaults, etag: etag);
  });

  @override
  Future<GlobalSettings> patch(
    Map<String, Object?> mergePatch, {
    String? etag,
  }) => guard(() async {
    await _settings.patchSettings(body: mergePatch, ifMatch: etag);
    return load();
  });

  @override
  Future<Schema> schema() => guard(_settings.getSettingsSchema);

  @override
  Future<EffectiveSettings> effectiveForTask(String id) => guard(
    () async => EffectiveSettings.of(
      await _api.rest.tasks.getTaskEffectiveSettings(id: id),
    ),
  );

  @override
  Future<EffectiveSettings> effectiveForQueue(String id) => guard(
    () async => EffectiveSettings.of(
      await _api.rest.queues.getQueueEffectiveSettings(id: id),
    ),
  );
}
