import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';

import '../problems/failure_presentation.dart';
import 'settings_repository.dart';

/// The value at the dotted [path] (`retry.maxAttempts`) of a JSON document, or
/// null when a step is missing.
Object? jsonAt(Map<String, Object?> json, String path) {
  Object? node = json;
  for (final step in path.split('.')) {
    if (node is! Map<String, Object?>) return null;
    node = node[step];
  }
  return node;
}

/// Applies an RFC 7396 merge patch to [base] and returns the result: objects
/// merge, `null` removes a key, anything else replaces.
Map<String, Object?> applyMergePatch(
  Map<String, Object?> base,
  Map<String, Object?> patch,
) {
  final out = {...base};
  for (final entry in patch.entries) {
    final value = entry.value;
    if (value == null) {
      out.remove(entry.key);
    } else if (value is Map<String, Object?>) {
      final current = out[entry.key];
      out[entry.key] = applyMergePatch(
        current is Map<String, Object?> ? current : const {},
        value,
      );
    } else {
      out[entry.key] = value;
    }
  }
  return out;
}

/// What a settings form starts from: what one level stores, and what applies
/// as a result, with the level each value comes from.
class SettingsSnapshot {
  /// Creates a snapshot.
  const SettingsSnapshot({
    required this.level,
    required this.overrides,
    required this.effective,
    this.sources = const {},
    this.inherited = const {},
    this.etag,
  });

  /// A snapshot of the global layer over the built-in defaults.
  factory SettingsSnapshot.global(GlobalSettings g) {
    final stored = _clean(_json(g.settings));
    final defaults = _clean(_json(g.defaults));
    final effective = applyMergePatch(defaults, stored);
    return SettingsSnapshot(
      level: SettingLevel.global,
      overrides: stored,
      effective: effective,
      sources: {
        for (final path in leafPaths(effective))
          path: jsonAt(stored, path) != null
              ? SettingLevel.global
              : SettingLevel.defaults,
      },
      inherited: defaults,
      etag: g.etag,
    );
  }

  /// A snapshot of a queue's or task's overrides with the daemon's resolved
  /// values.
  factory SettingsSnapshot.of(
    SettingLevel level,
    Settings stored,
    EffectiveSettings effective,
  ) {
    final values = _clean(_json(effective.settings));
    return SettingsSnapshot(
      level: level,
      overrides: _clean(_json(stored)),
      effective: values,
      sources: {
        for (final path in leafPaths(values)) path: effective.levelOf(path),
      },
    );
  }

  /// The level being edited.
  final SettingLevel level;

  /// What this level stores.
  final Map<String, Object?> overrides;

  /// What applies, this level included.
  final Map<String, Object?> effective;

  /// The level each value of [effective] comes from, by path.
  final Map<String, SettingLevel> sources;

  /// What applies below this level, when known (the defaults, for the global
  /// layer): the value a reset field falls back to.
  final Map<String, Object?> inherited;

  /// Version of the stored layer, when the daemon gives one.
  final String? etag;

  /// The plain JSON of [settings] (nested objects as maps).
  static Map<String, Object?> _json(Settings settings) =>
      jsonDecode(jsonEncode(settings.toJson())) as Map<String, Object?>;

  static Map<String, Object?> _clean(Map<String, Object?> json) {
    final out = <String, Object?>{};
    for (final e in json.entries) {
      if (e.key == r'$schema' || e.value == null) continue;
      final v = e.value;
      if (v is Map<String, Object?>) {
        final inner = _clean(v);
        if (inner.isNotEmpty) out[e.key] = inner;
      } else {
        out[e.key] = v;
      }
    }
    return out;
  }
}

/// The dotted paths of every non-object value of [json].
List<String> leafPaths(Map<String, Object?> json, [String prefix = '']) => [
  for (final e in json.entries)
    if (e.value is Map<String, Object?>)
      ...leafPaths(e.value! as Map<String, Object?>, '$prefix${e.key}.')
    else
      '$prefix${e.key}',
];

/// A form's working copy of one level's settings.
///
/// Edits are kept apart from what is stored: [patch] is the merge patch that
/// would turn the stored overrides into the edited ones, and a field can be
/// reset to inherit (its override removed). Field errors from a refused save
/// are kept per path until the field is edited again.
class SettingsDraft {
  /// Starts a draft of [snapshot].
  SettingsDraft(this.snapshot);

  /// What the draft started from.
  final SettingsSnapshot snapshot;

  // path -> new value; a null value means "remove the override".
  final Map<String, Object?> _edits = {};
  final Map<String, List<String>> _errors = {};

  /// Whether anything differs from what is stored.
  bool get isDirty => _edits.isNotEmpty;

  /// The paths that were edited.
  Iterable<String> get editedPaths => _edits.keys;

  /// The value to show for [path]: the edit, else what applies now.
  Object? valueOf(String path) {
    if (_edits.containsKey(path)) {
      final edit = _edits[path];
      // A reset field shows what it inherits: the value without this level.
      return edit ?? inheritedValueOf(path);
    }
    return jsonAt(snapshot.effective, path);
  }

  /// The value [path] would have without an override at this level, when it
  /// is known; else null.
  Object? inheritedValueOf(String path) {
    final below = jsonAt(snapshot.inherited, path);
    if (below != null) return below;
    // Without an override here, the effective value is the inherited one;
    // with one, the lower value is unknown and the field shows empty.
    return jsonAt(snapshot.overrides, path) == null
        ? jsonAt(snapshot.effective, path)
        : null;
  }

  /// Whether this level sets [path] (as edited so far).
  bool isOverridden(String path) {
    if (_edits.containsKey(path)) return _edits[path] != null;
    return jsonAt(snapshot.overrides, path) != null;
  }

  /// The level the shown value of [path] comes from.
  SettingLevel levelOf(String path) {
    if (isOverridden(path)) return snapshot.level;
    final source = snapshot.sources[path] ?? SettingLevel.defaults;
    // A reset field falls back to a lower level than this one.
    return source == snapshot.level ? SettingLevel.defaults : source;
  }

  /// Counts the changes that put values back (a reset, a revert): editors of
  /// lists and maps keep their own rows and start over when it changes.
  int get revision => _revision;
  int _revision = 0;

  /// Sets [path] to [value] (a number, text, a list or a map). Setting what is
  /// stored removes the edit.
  void set(String path, Object value) {
    _errors.remove(path);
    final stored = jsonAt(snapshot.overrides, path);
    if (stored != null && jsonEncode(stored) == jsonEncode(value)) {
      _edits.remove(path);
    } else {
      _edits[path] = value;
    }
  }

  /// Resets [path] to inherit (the override is removed on save).
  void reset(String path) {
    _revision++;
    _errors.remove(path);
    if (jsonAt(snapshot.overrides, path) == null) {
      _edits.remove(path);
    } else {
      _edits[path] = null;
    }
  }

  /// Drops every edit.
  void revert() {
    _revision++;
    _edits.clear();
    _errors.clear();
  }

  /// The RFC 7396 merge patch of the edits: new values, and `null` for
  /// removed overrides, nested the way the settings are.
  Map<String, Object?> get patch {
    final out = <String, Object?>{};
    for (final e in _edits.entries) {
      final steps = e.key.split('.');
      var node = out;
      for (final step in steps.take(steps.length - 1)) {
        node = (node[step] ??= <String, Object?>{}) as Map<String, Object?>;
      }
      node[steps.last] = e.value;
    }
    return out;
  }

  /// The overrides as they will be after the edits are saved.
  Map<String, Object?> get result => applyMergePatch(snapshot.overrides, patch);

  /// The errors of [path] from the last refused save.
  List<String> errorsOf(String path) => _errors[path] ?? const [];

  /// Whether the last refused save left errors.
  bool get hasErrors => _errors.isNotEmpty;

  /// Keeps the field errors of a refused save ([problem], a 422).
  void applyProblem(ApiProblem problem) {
    _errors
      ..clear()
      ..addAll(fieldErrorsOf(problem));
  }

  /// The errors that name no known field of the form (shown above it).
  List<String> unmatchedErrors(Set<String> knownPaths) => [
    for (final e in _errors.entries)
      if (!knownPaths.contains(e.key)) ...e.value,
  ];
}
