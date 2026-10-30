import 'dart:convert';
import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

Map<String, Object?> health({
  int api = 1,
  int minClient = 1,
  bool authenticated = true,
}) => {
  'status': 'ok',
  'version': '0.3.0',
  'apiVersion': api,
  'minClientApi': minClient,
  'authenticated': authenticated,
};

Future<String> daemon(Map<String, Object?> body) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((r) async {
    r.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await r.response.close();
  });
  addTearDown(() => server.close(force: true));
  return 'http://127.0.0.1:${server.port}';
}

ConnectionProfile remote(String url, {String? pin}) => ConnectionProfile(
  id: 'r',
  name: 'R',
  kind: ProfileKind.remote,
  url: url,
  tlsPin: pin,
);

void main() {
  final connector = ProfileConnector();

  test('connects to a compatible daemon', () async {
    final url = await daemon(health());
    final out = await connector.connect(remote(url), token: 'tok');
    addTearDown(() => (out as Connected).api.close(force: true));
    expect(out, isA<Connected>());
    expect((out as Connected).health.version, '0.3.0');
    expect(out.compatibility, isA<Compatible>());
  });

  test('the local profile connects to the URL the supervisor gives', () async {
    final url = await daemon(health());
    final out = await connector.connect(
      const ConnectionProfile.local(),
      token: 't',
      localUrl: url,
    );
    expect(out, isA<Connected>());
    (out as Connected).api.close(force: true);
  });

  test('the local profile without a URL cannot connect', () async {
    final out = await connector.connect(const ConnectionProfile.local());
    expect(out, isA<ConnectFailed>());
  });

  test('a daemon that wants a newer app is reported', () async {
    final url = await daemon(health(minClient: 2));
    final out = await connector.connect(remote(url), token: 't');
    expect(out, isA<Incompatible>());
    expect(
      ((out as Incompatible).compatibility as AppTooOld).daemonMinClientApi,
      2,
    );
  });

  test('a daemon older than the app supports is reported', () async {
    final url = await daemon(health(api: 0, minClient: 0));
    final out = await connector.connect(remote(url), token: 't');
    expect((out as Incompatible).compatibility, isA<DaemonTooOld>());
  });

  test('a rejected or missing token is reported', () async {
    final url = await daemon(health(authenticated: false));
    expect(
      await connector.connect(remote(url), token: 'bad'),
      isA<TokenRejected>(),
    );
    // No token is rejected too: the app would open and every call would 401.
    expect(await connector.connect(remote(url)), isA<TokenRejected>());
  });

  test('a daemon that needs no token connects without one', () async {
    final url = await daemon(health());
    final out = await connector.connect(remote(url));
    expect(out, isA<Connected>());
    (out as Connected).api.close(force: true);
  });

  test('an unreachable daemon is a failure with its reason', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close(force: true);
    final out = await connector.connect(remote('http://127.0.0.1:$port'));
    expect(out, isA<ConnectFailed>());
    expect((out as ConnectFailed).failure, isA<ApiConnectionFailure>());
    expect(out.certificateChanged, isFalse);
  });

  test('an invalid address fails without a network call', () async {
    expect(await connector.connect(remote('not a url')), isA<ConnectFailed>());
    expect(
      await connector.connect(
        const ConnectionProfile(id: 'r', name: 'R', kind: ProfileKind.remote),
      ),
      isA<ConnectFailed>(),
    );
  });

  test('https without a pin asks the user to trust the certificate', () async {
    final cert = PresentedCertificate(
      pin: 'sha256:abc',
      subject: 'CN=nas',
      issuer: 'CN=nas',
      validUntil: DateTime.utc(2030),
    );
    String? asked;
    final c = ProfileConnector(
      fetchCertificate: (host, port) async {
        asked = '$host:$port';
        return cert;
      },
    );
    final out = await c.connect(remote('https://nas.lan:17171'), token: 't');
    expect(out, isA<NeedsTrust>());
    expect((out as NeedsTrust).certificate.pin, 'sha256:abc');
    expect(asked, 'nas.lan:17171');
  });

  test('a failing certificate probe is a connection failure', () async {
    final c = ProfileConnector(
      fetchCertificate: (_, _) async => throw const SocketException('refused'),
    );
    expect(await c.connect(remote('https://nas.lan:1')), isA<ConnectFailed>());
  });

  test('https with a pin never asks again, it connects pinned', () async {
    var probed = false;
    DlmEndpoint? seen;
    final c = ProfileConnector(
      fetchCertificate: (_, _) async {
        probed = true;
        throw StateError('must not probe');
      },
      createApi: (e) {
        seen = e;
        return DlmApi(e);
      },
    );
    final out = await c.connect(
      remote('https://127.0.0.1:1', pin: 'sha256:aa'),
      token: 't',
    );
    expect(probed, isFalse);
    expect(seen!.adapter, isNotNull, reason: 'the pinned adapter is installed');
    expect(out, isA<ConnectFailed>(), reason: 'nothing listens on port 1');
  });
}
