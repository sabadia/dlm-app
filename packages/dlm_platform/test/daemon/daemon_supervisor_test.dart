import 'dart:async';
import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_daemon.dart';

void main() {
  late Directory dir;
  late FakeDaemons fake;
  late DaemonSupervisor sup;

  DaemonSupervisor supervisor({
    String? expectedVersion,
    RestartPolicy policy = const RestartPolicy(
      initialDelay: Duration(milliseconds: 20),
      maxDelay: Duration(milliseconds: 80),
      maxCrashes: 3,
    ),
    Duration startTimeout = const Duration(seconds: 5),
  }) => DaemonSupervisor(
    executable: '/fake/dlm',
    home: dir.path,
    expectedVersion: expectedVersion,
    restartPolicy: policy,
    startTimeout: startTimeout,
    stopTimeout: const Duration(seconds: 2),
    pollInterval: const Duration(milliseconds: 10),
    watchInterval: const Duration(milliseconds: 50),
    launcher: fake.launch,
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_sup');
    fake = FakeDaemons(dir.path);
    sup = supervisor();
  });
  tearDown(() async {
    await sup.dispose();
    await fake.dispose();
    dir.deleteSync(recursive: true);
  });

  Future<DaemonStatus> next(bool Function(DaemonStatus) test) =>
      sup.status.firstWhere(test).timeout(const Duration(seconds: 30));

  test(
    'starts the daemon on a random loopback port and reports where',
    () async {
      await sup.start();
      expect(sup.current.phase, DaemonPhase.running);
      expect(sup.current.adopted, isFalse);
      expect(fake.launches.single, [
        'serve',
        '--home',
        dir.path,
        '--address',
        '127.0.0.1:0',
      ]);
      expect(sup.current.info!.url, startsWith('http://127.0.0.1:'));
      expect(sup.current.info!.version, '1.0.0');
      expect(sup.token(), 'tok');
    },
  );

  test('takes over a daemon that already runs for this home', () async {
    final other = await fake.external();
    await sup.start();
    expect(sup.current.phase, DaemonPhase.running);
    expect(sup.current.adopted, isTrue);
    expect(sup.current.info!.pid, other.pid);
    expect(fake.launches, isEmpty);
  });

  test('replaces a running daemon of another version', () async {
    await fake.external(versionOverride: '0.9.0');
    sup = supervisor(expectedVersion: '1.0.0');
    await sup.start();
    expect(fake.shutdowns, ['0.9.0']);
    expect(fake.launches, hasLength(1));
    expect(sup.current.info!.version, '1.0.0');
    expect(sup.current.adopted, isFalse);
  });

  test('keeps a running daemon of the expected version', () async {
    await fake.external();
    sup = supervisor(expectedVersion: '1.0.0');
    await sup.start();
    expect(fake.launches, isEmpty);
    expect(sup.current.adopted, isTrue);
  });

  test('a crash is reported with its reason and the daemon restarts', () async {
    await sup.start();
    final firstPid = sup.current.info!.pid;
    fake.launches.clear();
    // The daemon dies after saying why.
    final restarting = next((s) => s.phase == DaemonPhase.restarting);
    fake.launchedProcesses().last
      ..say('panic: out of memory')
      ..exit(2);
    final s = await restarting;
    expect(s.reason, contains('code 2'));
    expect(s.reason, contains('panic: out of memory'));
    expect(s.crashes, 1);
    final running = await next((s) => s.phase == DaemonPhase.running);
    expect(running.info!.pid, isNot(firstPid));
    expect(fake.launches, hasLength(1));
  });

  test('gives up after repeated crashes', () async {
    fake.script.addAll([
      'exit:1:boom',
      'exit:1:boom',
      'exit:1:boom',
      'exit:1:boom',
    ]);
    final failed = next((s) => s.phase == DaemonPhase.failed);
    await sup.start();
    final s = await failed;
    expect(s.reason, contains('boom'));
    expect(s.reason, contains('not restarting'));
    expect(fake.launches.length, 3);
  });

  test(
    'a start that ends because another daemon holds the lock adopts it',
    () async {
      fake.script.add('exit:1:another dlm daemon is already running');
      final other = Completer<void>();
      // The other daemon appears while ours is dying.
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 5), () async {
          await fake.external();
          other.complete();
        }),
      );
      await sup.start();
      await other.future;
      expect(sup.current.phase, DaemonPhase.running);
      expect(sup.current.adopted, isTrue);
    },
  );

  test('a daemon that never becomes ready fails and is killed', () async {
    fake.script.add('hang');
    sup = supervisor(startTimeout: const Duration(milliseconds: 150));
    await sup.start();
    expect(sup.current.phase, DaemonPhase.failed);
    expect(sup.current.reason, contains('did not become ready'));
    expect(fake.launchedProcesses().last.killed, isTrue);
  });

  test('a start whose launch throws fails with the reason', () async {
    sup = DaemonSupervisor(
      executable: '/missing/dlm',
      home: dir.path,
      launcher: (_, _) async =>
          throw const ProcessException('/missing/dlm', []),
    );
    await sup.start();
    expect(sup.current.phase, DaemonPhase.failed);
    expect(sup.current.reason, contains('could not be started'));
  });

  test('stop shuts the daemon down through the API', () async {
    await sup.start();
    final process = fake.launchedProcesses().last;
    await sup.stop();
    expect(fake.shutdowns, ['1.0.0']);
    expect(sup.current.phase, DaemonPhase.stopped);
    expect(await process.exitCode, 0);
    expect(process.terminated, isFalse);
  });

  test('dispose without stopping leaves the daemon running', () async {
    await sup.start();
    final url = sup.current.info!.url;
    await sup.dispose(stopDaemon: false);
    final client = HttpClient();
    final res = await (await client.getUrl(Uri.parse('$url/v1/health')))
        .close();
    expect(res.statusCode, 200);
    client.close(force: true);
  });

  test('a restart through the API is not counted as a crash', () async {
    await sup.start();
    final old = fake.launchedProcesses().last;
    // restart-daemon: the old process ends, a new one (new pid) takes over.
    unawaited(fake.external().then((_) {}));
    old.exit(0);
    final s = await next((s) => s.phase == DaemonPhase.running && s.adopted);
    expect(s.crashes, 0);
    expect(fake.launches.length, 1, reason: 'no replacement was started by us');
  });

  test('a restart that keeps the pid but changes the port is followed', () async {
    await sup.start();
    final before = sup.current.info!;
    final process = fake.launchedProcesses().last;
    // restart-daemon on Unix re-executes the same process: new port, same pid.
    await process.server!.close(force: true);
    await fake.serve(process);
    final s = await next((s) => s.info != null && s.info!.url != before.url);
    expect(s.phase, DaemonPhase.running);
    expect(s.info!.pid, before.pid);
    expect(s.crashes, 0);
  });

  test('an adopted daemon that stops answering is replaced', () async {
    final other = await fake.external();
    await sup.start();
    other.exit(0);
    final restarting = await next((s) => s.phase == DaemonPhase.restarting);
    expect(restarting.reason, contains('stopped answering'));
    final running = await next((s) => s.phase == DaemonPhase.running);
    expect(running.adopted, isFalse);
    expect(fake.launches, hasLength(1));
  });

  test('locator prefers the override, then the bundle, then PATH', () {
    final l = DaemonLocator(
      environment: {'DLM_DAEMON': '/x/dlm', 'PATH': '/usr/bin:/opt/bin'},
      executable: '/Apps/dlm.app/Contents/MacOS/dlm_app',
      operatingSystem: 'macos',
      exists: (p) => p == '/opt/bin/dlm',
    );
    expect(l.candidates(), [
      '/x/dlm',
      '/Apps/dlm.app/Contents/MacOS/../Resources/bin/dlm',
      '/usr/bin/dlm',
      '/opt/bin/dlm',
    ]);
    expect(l.find(), '/opt/bin/dlm');
    final win = DaemonLocator(
      environment: {'Path': r'C:\tools'},
      executable: r'C:\App\dlm_app.exe',
      operatingSystem: 'windows',
      exists: (_) => false,
    );
    expect(win.candidates(), [r'C:\App\bin\dlm.exe', r'C:\tools\dlm.exe']);
    expect(win.find(), isNull);
  });
}
