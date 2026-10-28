import 'dart:convert';
import 'dart:io';

import 'profile.dart';
import 'token_vault.dart';

/// The saved profiles: a JSON file (no secrets) plus a [TokenVault].
///
/// The local profile always exists. A damaged file is moved aside
/// (`<file>.corrupt`) and replaced by the defaults instead of blocking startup.
class ProfileStore {
  /// Creates a store over [file].
  ProfileStore({required this.file, required this.vault});

  /// The JSON file.
  final File file;

  /// Where tokens live.
  final TokenVault vault;

  /// All profiles, the local one first.
  Future<List<ConnectionProfile>> load() async {
    final stored = await _read();
    final remotes = stored.where((p) => !p.isLocal).toList();
    final local = stored.where((p) => p.isLocal).firstOrNull;
    return [local ?? const ConnectionProfile.local(), ...remotes];
  }

  /// Adds or replaces [profile]; with [token] also stores its token.
  Future<void> save(ConnectionProfile profile, {String? token}) async {
    final all = await _read();
    final next = [
      for (final p in all)
        if (p.id != profile.id) p,
      profile,
    ];
    await _write(next);
    if (token != null) await vault.write(profile.id, token);
  }

  /// Removes a remote profile and its token. The local profile cannot be
  /// removed.
  Future<void> delete(String id) async {
    if (id == ConnectionProfile.localId) {
      throw ArgumentError.value(
        id,
        'id',
        'the local profile cannot be deleted',
      );
    }
    final all = await _read();
    await _write([
      for (final p in all)
        if (p.id != id) p,
    ]);
    await vault.delete(id);
  }

  /// The token of profile [id].
  Future<String?> token(String id) => vault.read(id);

  Future<List<ConnectionProfile>> _read() async {
    if (!file.existsSync()) return const [];
    try {
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, Object?> || json['profiles'] is! List<Object?>) {
        throw const FormatException('profiles missing');
      }
      return [
        for (final p in json['profiles']! as List<Object?>)
          ConnectionProfile.fromJson(p! as Map<String, Object?>),
      ];
    } on Object {
      // Keep the evidence, start fresh.
      final aside = File('${file.path}.corrupt');
      if (aside.existsSync()) aside.deleteSync();
      file.renameSync(aside.path);
      return const [];
    }
  }

  Future<void> _write(List<ConnectionProfile> profiles) async {
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'profiles': [for (final p in profiles) p.toJson()],
      }),
      flush: true,
    );
    await tmp.rename(file.path);
  }
}
