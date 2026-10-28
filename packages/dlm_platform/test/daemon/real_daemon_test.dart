@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs the supervisor against the real `dlm` binary:
/// `DLM_BIN=/path/to/dlm flutter test --tags integration`.
void main() {
  final bin = Platform.environment['DLM_BIN'];

  Future<Map<String, Object?>> getJson(String url, String token) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('Authorization', 'Bearer $token');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      return jsonDecode(body) as Map<String, Object?>;
    } finally {
      client.close(force: true);
    }
  }

  test(
    'starts, follows a restart and stops the real daemon',
    () async {
      final home = Directory.systemTemp.createTempSync('dlm_real');
      final sup = DaemonSupervisor(
        executable: bin!,
        home: home.path,
        watchInterval: const Duration(milliseconds: 200),
      );
      addTearDown(() async {
        await sup.dispose();
        home.deleteSync(recursive: true);
      });

      await sup.start();
      expect(sup.current.phase, DaemonPhase.running, reason: '${sup.current}');
      final first = sup.current.info!;
      expect(first.url, startsWith('http://127.0.0.1:'));
      expect(first.url, isNot(endsWith(':0')));

      final token = sup.token()!;
      final info = await getJson('${first.url}/v1/system/info', token);
      expect(info['pid'], first.pid);
      expect(
        (info['paths']! as Map<String, Object?>)['config'],
        contains(home.path.split('/').last),
      );

      // A second supervisor on the same home takes the running daemon over.
      final second = DaemonSupervisor(executable: bin, home: home.path);
      await second.start();
      expect(second.current.adopted, isTrue);
      expect(second.current.info!.pid, first.pid);
      await second.dispose(stopDaemon: false);

      // restart-daemon: the daemon stops and starts again; the supervisor
      // follows it to its new address without calling it a crash.
      final client = HttpClient();
      final req = await client.postUrl(
        Uri.parse('${first.url}/v1/system/restart'),
      );
      req.headers.set('Authorization', 'Bearer $token');
      expect((await req.close()).statusCode, 202);
      client.close(force: true);
      final after = await sup.status
          .firstWhere(
            (s) => s.phase == DaemonPhase.running && s.info!.url != first.url,
          )
          .timeout(const Duration(seconds: 30));
      expect(sup.current.crashes, 0);
      expect(
        (await getJson('${after.info!.url}/v1/health', token))['status'],
        'ok',
      );

      await sup.stop();
      expect(sup.current.phase, DaemonPhase.stopped);
      expect(
        RuntimeInfo.read(home.path),
        isNull,
        reason: 'runtime.json is removed on a clean stop',
      );
    },
    skip: bin == null ? 'set DLM_BIN to the dlm executable to run this' : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
