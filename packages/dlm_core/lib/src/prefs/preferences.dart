import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Turns a stored file written by an older version into the current layout.
/// Migration `i` upgrades version `i + 1` to `i + 2`.
typedef PreferencesMigration = Map<String, Object?> Function(
  Map<String, Object?> values,
);

/// One preference: its key, default and how it is stored.
class Pref<T> {
  /// Creates a preference. [decode] gets whatever the file holds and must
  /// throw (or return null) for a value it does not understand, which then
  /// reads as the default.
  const Pref(this.key, this.defaultValue, this.decode, this.encode);

  /// A preference stored as is (bool, int, double, String).
  const Pref.plain(this.key, this.defaultValue)
    : decode = _plain,
      encode = _identity;

  /// The key in the file, `area.name`.
  final String key;

  /// What reads when nothing is stored (or the stored value is unusable).
  final T defaultValue;

  /// File value to [T].
  final T? Function(Object? raw) decode;

  /// [T] to file value.
  final Object? Function(T value) encode;

  static T? _plain<T>(Object? raw) => raw is T ? raw : null;
  static Object? _identity(Object? v) => v;
}

/// A preference stored as the name of an enum value.
Pref<E> enumPref<E extends Enum>(String key, List<E> values, E fallback) =>
    Pref<E>(
      key,
      fallback,
      (raw) => values.where((v) => v.name == raw).firstOrNull,
      (v) => v.name,
    );

/// UI preferences in one small JSON file, with a version and migrations.
///
/// Values live under a key, either global (`ui.density`) or per connection
/// profile (a remote daemon has its own column layout). Reads never fail: a
/// missing or unusable value is the default. A damaged file is moved aside
/// (`<file>.corrupt`) and the app starts with defaults; a file written by a
/// *newer* version is copied to `<file>.from-v<N>` before anything is saved,
/// so a downgrade cannot destroy settings.
class PreferencesStore {
  PreferencesStore._(this._file, this._values, this._version);

  /// Opens (and migrates) the file; a missing file is an empty store.
  static Future<PreferencesStore> open(
    File file, {
    List<PreferencesMigration> migrations = const [],
  }) async {
    final current = migrations.length + 1;
    var values = <String, Object?>{};
    var version = current;
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString());
        if (json is! Map<String, Object?>) {
          throw const FormatException('not an object');
        }
        final stored = json['version'];
        final data = json['values'];
        if (stored is! int || data is! Map<String, Object?>) {
          throw const FormatException('no version or values');
        }
        values = Map.of(data);
        version = stored;
      } on Object {
        final aside = File('${file.path}.corrupt');
        if (aside.existsSync()) aside.deleteSync();
        file.renameSync(aside.path);
      }
    }
    if (version > current) {
      // Written by a newer app: keep a copy, carry on with what we understand.
      await file.copy('${file.path}.from-v$version');
    }
    for (var v = version; v < current; v++) {
      values = migrations[v - 1](Map.of(values));
    }
    final store = PreferencesStore._(file, values, current);
    if (version != current && version < current) await store._save();
    return store;
  }

  final File _file;
  final Map<String, Object?> _values;
  final int _version;
  final _changes = StreamController<String>.broadcast(sync: true);
  Future<void> _writing = Future.value();

  /// The version of the layout this store writes.
  int get version => _version;

  /// Fires the full key of every preference that changes.
  Stream<String> get changes => _changes.stream;

  String _key(Pref<Object?> p, String? profile) =>
      profile == null ? p.key : 'profiles.$profile.${p.key}';

  /// Reads [pref] (for [profile] when given).
  T get<T>(Pref<T> pref, {String? profile}) {
    final raw = _values[_key(pref, profile)];
    if (raw == null) return pref.defaultValue;
    try {
      return pref.decode(raw) ?? pref.defaultValue;
    } on Object {
      return pref.defaultValue;
    }
  }

  /// Whether [pref] has been set.
  bool isSet(Pref<Object?> pref, {String? profile}) =>
      _values.containsKey(_key(pref, profile));

  /// Stores [value]; completes when it is on disk.
  Future<void> set<T>(Pref<T> pref, T value, {String? profile}) {
    final key = _key(pref, profile);
    _values[key] = pref.encode(value);
    _changes.add(key);
    return _save();
  }

  /// Forgets [pref]; it reads as its default again.
  Future<void> reset(Pref<Object?> pref, {String? profile}) {
    final key = _key(pref, profile);
    if (_values.remove(key) == null) return _writing;
    _changes.add(key);
    return _save();
  }

  /// Forgets everything stored for connection profile [profile] (it was
  /// deleted).
  Future<void> forgetProfile(String profile) {
    final prefix = 'profiles.$profile.';
    final gone = _values.keys.where((k) => k.startsWith(prefix)).toList();
    for (final k in gone) {
      _values.remove(k);
      _changes.add(k);
    }
    return gone.isEmpty ? _writing : _save();
  }

  /// Waits for pending writes.
  Future<void> flush() => _writing;

  /// Releases the change stream (after pending writes).
  Future<void> dispose() async {
    await _writing;
    await _changes.close();
  }

  Future<void> _save() {
    // One write at a time, each writing the latest state: concurrent set()
    // calls never interleave or lose each other.
    return _writing = _writing.onError<Object>((_, _) {}).then((_) async {
      await _file.parent.create(recursive: true);
      final tmp = File('${_file.path}.tmp');
      await tmp.writeAsString(
        const JsonEncoder.withIndent('  ')
            .convert({'version': _version, 'values': _values}),
        flush: true,
      );
      await tmp.rename(_file.path);
    });
  }
}
