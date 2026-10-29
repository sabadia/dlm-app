import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/connection/connection_controller.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _remote = ConnectionProfile(
  id: 'nas',
  name: 'NAS',
  kind: ProfileKind.remote,
  url: 'https://nas.lan:7777',
  tlsPin: 'sha256:aa',
);

ProviderContainer _container({
  required FakeConnector connector,
  FakeDaemon? daemon,
  ConnectionProfile profile = const ConnectionProfile.local(),
  MemoryVault? vault,
}) {
  final v = vault ?? MemoryVault();
  final c = ProviderContainer(
    overrides: [
      localDaemonProvider.overrideWithValue(daemon ?? FakeDaemon()),
      connectorProvider.overrideWithValue(connector),
      profileStoreProvider.overrideWithValue(tempProfileStore(v)),
      activeProfileProvider.overrideWithValue(profile),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Future<ConnectionStatus> _settled(ProviderContainer c) async {
  c.read(connectionProvider);
  for (var i = 0; i < 50; i++) {
    await Future<void>.delayed(Duration.zero);
    if (c.read(connectionProvider) is! Connecting) break;
  }
  return c.read(connectionProvider);
}

void main() {
  test('starts connecting', () {
    final c = _container(
      connector: FakeConnector(
        (p, t, u) => Connected(offlineApi(), health(), const Compatible()),
      ),
    );
    expect(c.read(connectionProvider), isA<Connecting>());
  });

  test('a local profile starts the daemon and connects with its address and '
      'token', () async {
    final daemon = FakeDaemon();
    final connector = FakeConnector(
      (p, t, u) => Connected(offlineApi(), health(), const Compatible()),
    );
    final c = _container(daemon: daemon, connector: connector);
    final status = await _settled(c);
    expect(status, isA<Ready>());
    expect(daemon.starts, 1);
    final (profile, token, url) = connector.calls.single;
    expect(profile.isLocal, isTrue);
    expect(token, 'daemon-token');
    expect(url, 'http://127.0.0.1:7777');
  });

  test(
    'a daemon that cannot start is a failed connection with its reason',
    () async {
      final daemon = FakeDaemon(
        phase: DaemonPhase.failed,
        reason: 'port in use',
      );
      final connector = FakeConnector(
        (p, t, u) => throw StateError('must not connect'),
      );
      final c = _container(daemon: daemon, connector: connector);
      final status = await _settled(c);
      expect(status, isA<ConnectionFailedStatus>());
      expect((status as ConnectionFailedStatus).reason, 'port in use');
      expect(connector.calls, isEmpty);
    },
  );

  test('a remote profile uses the stored token and its own url', () async {
    final vault = MemoryVault()..tokens['nas'] = 'remote-token';
    final connector = FakeConnector(
      (p, t, u) => Connected(offlineApi(), health(), const Compatible()),
    );
    final daemon = FakeDaemon();
    final c = _container(
      daemon: daemon,
      connector: connector,
      profile: _remote,
      vault: vault,
    );
    await _settled(c);
    final (_, token, url) = connector.calls.single;
    expect(token, 'remote-token');
    expect(url, isNull);
    expect(
      daemon.starts,
      0,
      reason: 'a remote profile never starts the daemon',
    );
  });

  test('each connector outcome maps to a status', () async {
    final cases = <ConnectOutcome, Type>{
      NeedsTrust(
        PresentedCertificate(
          pin: 'sha256:bb',
          subject: 'nas',
          issuer: 'nas',
          validUntil: DateTime(2030),
        ),
      ): NeedsTrustStatus,
      Incompatible(const AppTooOld(9), health()): IncompatibleStatus,
      const TokenRejected(): TokenRejectedStatus,
      const ConnectFailed(
        ApiConnectionFailure('down'),
        certificateChanged: true,
      ): ConnectionFailedStatus,
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      final c = _container(
        connector: FakeConnector((p, t, u) => key),
        profile: _remote,
      );
      final status = await _settled(c);
      expect(status.runtimeType, value, reason: '$key');
    }
  });

  test('a failure carries the certificate-changed flag', () async {
    final c = _container(
      connector: FakeConnector(
        (p, t, u) => const ConnectFailed(
          ApiConnectionFailure('x'),
          certificateChanged: true,
        ),
      ),
      profile: _remote,
    );
    final status = await _settled(c) as ConnectionFailedStatus;
    expect(status.certificateChanged, isTrue);
    expect(status.failure, isA<ApiConnectionFailure>());
  });

  test('an exception becomes a failed connection, not a crash', () async {
    final c = _container(
      connector: FakeConnector((p, t, u) => throw const FormatException('bad')),
    );
    final status = await _settled(c);
    expect(status, isA<ConnectionFailedStatus>());
    expect((status as ConnectionFailedStatus).reason, contains('bad'));
  });

  test(
    'retrying connects again and a later success replaces the failure',
    () async {
      var fail = true;
      final connector = FakeConnector(
        (p, t, u) => fail
            ? const ConnectFailed(ApiConnectionFailure('down'))
            : Connected(offlineApi(), health(), const Compatible()),
      );
      final c = _container(connector: connector);
      expect(await _settled(c), isA<ConnectionFailedStatus>());
      fail = false;
      unawaited(c.read(connectionProvider.notifier).connect());
      expect(c.read(connectionProvider), isA<Connecting>());
      expect(await _settled(c), isA<Ready>());
      expect(connector.calls.length, 2);
    },
  );

  test('a newer attempt wins over a slower older one', () async {
    final gate = Completer<void>();
    var calls = 0;
    final connector = FakeConnector((p, t, u) {
      calls++;
      return calls == 1
          ? const ConnectFailed(ApiConnectionFailure('stale'))
          : Connected(offlineApi(), health(), const Compatible());
    })..gate = gate.future;
    final c = _container(connector: connector)..read(connectionProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    final second = c.read(connectionProvider.notifier).connect();
    gate.complete();
    await second;
    await Future<void>.delayed(Duration.zero);
    expect(c.read(connectionProvider), isA<Ready>());
  });

  test(
    'trusting a certificate pins it on the profile and reconnects',
    () async {
      final vault = MemoryVault();
      final store = tempProfileStore(vault);
      final connector = FakeConnector((p, t, u) {
        return NeedsTrust(
          PresentedCertificate(
            pin: 'sha256:bb',
            subject: 'nas',
            issuer: 'nas',
            validUntil: DateTime(2030),
          ),
        );
      });
      final c = ProviderContainer(
        overrides: [
          localDaemonProvider.overrideWithValue(FakeDaemon()),
          connectorProvider.overrideWithValue(connector),
          profileStoreProvider.overrideWithValue(store),
          activeProfileProvider.overrideWithValue(_remote.copyWith(tlsPin: '')),
        ],
      );
      addTearDown(c.dispose);
      final first = await _settled(c);
      expect(first, isA<NeedsTrustStatus>());
      // The pin is read from the active profile; after trusting, the stored
      // profile carries it.
      await c
          .read(connectionProvider.notifier)
          .trust((first as NeedsTrustStatus).certificate);
      final stored = (await store.load()).firstWhere((p) => p.id == 'nas');
      expect(stored.tlsPin, 'sha256:bb');
    },
  );
}
