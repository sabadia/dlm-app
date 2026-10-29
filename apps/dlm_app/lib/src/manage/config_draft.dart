import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';

/// The boot configuration being edited: what the daemon reports plus the
/// user's edits. A change takes effect after a restart; until then the daemon
/// keeps both the running value and the pending one.
class ConfigDraft {
  /// Starts a draft of [view].
  ConfigDraft(this.view);

  /// What the daemon reported.
  final ConfigView view;

  final Map<String, Object?> _edits = {};

  /// Whether anything was edited.
  bool get isDirty => _edits.isNotEmpty;

  /// The value to show for [key]: the edit, else the value waiting for a
  /// restart, else the running one.
  Object? valueOf(String key) {
    if (_edits.containsKey(key)) return _edits[key];
    final entry = _entry(key);
    return entry?.pending ?? entry?.value;
  }

  /// Whether [key] was edited.
  bool isEdited(String key) => _edits.containsKey(key);

  /// Sets [key]; setting what is shown already is no change.
  void set(String key, Object? value) {
    final entry = _entry(key);
    final current = entry?.pending ?? entry?.value;
    if (_same(current, value)) {
      _edits.remove(key);
    } else {
      _edits[key] = value;
    }
  }

  /// Drops the edit of [key].
  void unset(String key) => _edits.remove(key);

  /// Drops every edit.
  void revert() => _edits.clear();

  /// What to send: the edited keys with their new values.
  Map<String, Object?> get patch => Map.of(_edits);

  /// Whether the edit of [key] needs a restart to take effect.
  bool needsRestart(String key) => _entry(key)?.restartRequired ?? false;

  /// Whether any edit needs a restart.
  bool get editsNeedRestart => _edits.keys.any(needsRestart);

  Entry? _entry(String key) {
    for (final e in view.entries ?? const <Entry>[]) {
      if (e.key == key) return e;
    }
    return null;
  }

  static bool _same(Object? a, Object? b) {
    if (a is List && b is List) {
      return a.length == b.length &&
          [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);
    }
    return a == b;
  }
}
