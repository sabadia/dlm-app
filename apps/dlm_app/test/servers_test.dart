import 'dart:io';

import 'package:dlm_app/src/connection/connection_controller.dart';
import 'package:dlm_app/src/manage/servers_group.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

Future<ProviderContainer> _container() async {
  final dir = Directory.systemTemp.createTempSync('dlm_servers');
  addTearDown(() => dir.deleteSync(recursive: true));
  final prefs = await PreferencesStore.open(File('${dir.path}/prefs.json'));
  final c = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      profileStoreProvider.overrideWithValue(tempProfileStore(MemoryVault())),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('the bundled daemon is in use until a server is chosen', () async {
    final c = await _container();
    expect(c.read(activeProfileProvider).isLocal, isTrue);
    expect(c.read(profilesProvider).single.isLocal, isTrue);
  });

  test('a saved server can be used, and removing it goes back', () async {
    final c = await _container();
    final server = await c
        .read(profilesProvider.notifier)
        .addServer(name: 'NAS', url: 'https://nas.lan:7777', token: 'tok');
    expect(c.read(profilesProvider).map((p) => p.name), [
      'This computer',
      'NAS',
    ]);
    expect(await c.read(profileStoreProvider).token(server.id), 'tok');

    await c.read(activeProfileIdProvider.notifier).set(server.id);
    expect(c.read(activeProfileProvider).id, server.id);
    expect(c.read(activeProfileProvider).url, 'https://nas.lan:7777');

    await c.read(profilesProvider.notifier).remove(server.id);
    expect(c.read(activeProfileProvider).isLocal, isTrue);
    expect(c.read(profilesProvider), hasLength(1));
    expect(await c.read(profileStoreProvider).token(server.id), isNull);
  });

  test('a profile that is gone falls back to the bundled daemon', () async {
    final c = await _container();
    await c.read(activeProfileIdProvider.notifier).set('missing');
    expect(c.read(activeProfileProvider).isLocal, isTrue);
  });

  test('an address needs a scheme and a host; a path is dropped', () {
    expect(
      ServersGroupState.parseAddress('https://nas.lan:7777/'),
      'https://nas.lan:7777',
    );
    expect(
      ServersGroupState.parseAddress(' http://10.0.0.5:7777/v1 '),
      'http://10.0.0.5:7777',
    );
    expect(ServersGroupState.parseAddress('nas.lan:7777'), isNull);
    expect(ServersGroupState.parseAddress('ftp://nas.lan'), isNull);
    expect(ServersGroupState.parseAddress(''), isNull);
  });
}
