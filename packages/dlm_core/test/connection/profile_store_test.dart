import 'dart:convert';
import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late File file;
  late MemoryTokenVault vault;
  late ProfileStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_profiles');
    file = File('${dir.path}/profiles.json');
    vault = MemoryTokenVault();
    store = ProfileStore(file: file, vault: vault);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  const nas = ConnectionProfile(
    id: 'nas',
    name: 'NAS',
    kind: ProfileKind.remote,
    url: 'https://nas.lan:17171',
    tlsPin: 'sha256:aa',
  );

  test('a fresh store has only the local profile', () async {
    final all = await store.load();
    expect(all, [const ConnectionProfile.local()]);
    expect(all.single.isLocal, isTrue);
  });

  test('saving keeps the token in the vault, not in the file', () async {
    await store.save(nas, token: 'secret-token');
    expect(await store.token('nas'), 'secret-token');
    expect(file.readAsStringSync(), isNot(contains('secret-token')));
    final all = await store.load();
    expect(all.map((p) => p.id), ['local', 'nas']);
    expect(all.last, nas);
  });

  test('saving again replaces; the token is kept unless given', () async {
    await store.save(nas, token: 't1');
    await store.save(nas.copyWith(name: 'Renamed'));
    expect((await store.load()).last.name, 'Renamed');
    expect(await store.token('nas'), 't1');
    await store.save(nas, token: 't2');
    expect(await store.token('nas'), 't2');
  });

  test('deleting removes the profile and its token; local stays', () async {
    await store.save(nas, token: 't');
    await store.delete('nas');
    expect((await store.load()).map((p) => p.id), ['local']);
    expect(await store.token('nas'), isNull);
    expect(() => store.delete('local'), throwsArgumentError);
  });

  test('a damaged file is moved aside and the defaults are used', () async {
    file.writeAsStringSync('{ not json');
    expect(await store.load(), [const ConnectionProfile.local()]);
    expect(File('${file.path}.corrupt').existsSync(), isTrue);
    expect(file.existsSync(), isFalse);
    await store.save(nas); // and the store works again
    expect((await store.load()).length, 2);
  });

  test('a file with a bad profile is treated as damaged', () async {
    file.writeAsStringSync(
      jsonEncode({
        'profiles': [
          {'id': 'x', 'name': 'X', 'kind': 'teleporter'},
        ],
      }),
    );
    expect(await store.load(), [const ConnectionProfile.local()]);
    expect(File('${file.path}.corrupt').existsSync(), isTrue);
  });

  test('profiles survive a JSON round trip', () {
    expect(ConnectionProfile.fromJson(nas.toJson()), nas);
    expect(
      () =>
          ConnectionProfile.fromJson({'id': '', 'name': 'x', 'kind': 'local'}),
      throwsFormatException,
    );
  });
}
