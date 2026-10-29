import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:test/test.dart';

Future<HttpServer> tlsServer() async {
  final context = SecurityContext()
    ..useCertificateChain('test/fixtures/test-cert.pem')
    ..usePrivateKey('test/fixtures/test-key.pem');
  final server = await HttpServer.bindSecure(
    InternetAddress.loopbackIPv4,
    0,
    context,
  );
  server.listen((r) async {
    r.response
      ..headers.contentType = ContentType.json
      ..write(
        '{"status":"ok","version":"t","apiVersion":1,"minClientApi":1,"authenticated":false}',
      );
    await r.response.close();
  });
  addTearDown(() => server.close(force: true));
  return server;
}

void main() {
  test(
    'fetchCertificate shows the presented certificate and its pin',
    () async {
      final server = await tlsServer();
      final cert = await fetchCertificate('127.0.0.1', server.port);
      // openssl x509 -fingerprint -sha256 of the fixture
      expect(
        displayFingerprint(cert.pin),
        'D5:2E:B8:90:56:18:B4:72:28:25:7F:6C:BC:5A:F8:A1:42:45:49:07:F0:F2:14:9A:6C:28:76:B9:E8:34:0A:C0',
      );
      expect(cert.selfSigned, isTrue);
      expect(cert.subject, contains('localhost'));
      expect(
        cert.validUntil.isAfter(DateTime.now().add(const Duration(days: 3650))),
        isTrue,
      );
    },
  );

  test('a client pinned to the right certificate connects', () async {
    final server = await tlsServer();
    final pin = (await fetchCertificate('127.0.0.1', server.port)).pin;
    final api = DlmApi(
      DlmEndpoint(
        baseUrl: 'https://127.0.0.1:${server.port}',
        adapter: pinnedAdapter(pin),
      ),
    );
    addTearDown(() => api.close(force: true));
    final health = await guard(() => api.rest.system.getHealth());
    expect(health.version, 't');
  });

  test(
    'a client pinned to another certificate refuses the connection',
    () async {
      final server = await tlsServer();
      final api = DlmApi(
        DlmEndpoint(
          baseUrl: 'https://127.0.0.1:${server.port}',
          adapter: pinnedAdapter('sha256:${'0' * 64}'),
        ),
      );
      addTearDown(() => api.close(force: true));
      await expectLater(
        guard(() => api.rest.system.getHealth()),
        throwsA(isA<ApiConnectionFailure>()),
      );
    },
  );

  test('an unpinned client does not trust a self-signed certificate', () async {
    final server = await tlsServer();
    final api = DlmApi(
      DlmEndpoint(baseUrl: 'https://127.0.0.1:${server.port}'),
    );
    addTearDown(() => api.close(force: true));
    await expectLater(
      guard(() => api.rest.system.getHealth()),
      throwsA(isA<ApiConnectionFailure>()),
    );
  });

  test('fingerprints format for people and parse from the daemon', () {
    expect(fingerprintOf([1, 2, 3]).startsWith('sha256:'), isTrue);
    expect(fingerprintOf([1, 2, 3]).length, 7 + 64);
    expect(displayFingerprint('sha256:abcd01'), 'AB:CD:01');
  });
}
