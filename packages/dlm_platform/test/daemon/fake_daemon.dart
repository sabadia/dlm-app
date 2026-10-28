import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';

/// An in-process stand-in for `dlm serve`: a real HTTP server plus the files a
/// real daemon leaves, behind the supervisor's [DaemonLauncher] interface.
class FakeDaemons {
  FakeDaemons(this.home, {this.token = 'tok'}) {
    Directory('$home/config').createSync(recursive: true);
    File('$home/config/token').writeAsStringSync('$token\n');
  }

  final String home;
  final String token;

  final launches = <List<String>>[];
  final shutdowns = <String>[];

  /// What the next launch does: `ok`, `exit:<code>:<stderr>`, `hang`.
  final script = <String>[];
  String version = '1.0.0';
  int _nextPid = 5000;
  final _live = <FakeProcess>[];
  final _launched = <FakeProcess>[];

  /// The processes the supervisor started, oldest first.
  List<FakeProcess> launchedProcesses() => _launched;

  Future<DaemonProcess> launch(String exe, List<String> args) async {
    launches.add(args);
    final step = script.isEmpty ? 'ok' : script.removeAt(0);
    final process = FakeProcess(_nextPid++);
    _live.add(process);
    _launched.add(process);
    if (step.startsWith('exit:')) {
      final parts = step.split(':');
      Timer(const Duration(milliseconds: 20), () {
        if (parts.length > 2) process.say(parts.sublist(2).join(':'));
        process.exit(int.parse(parts[1]));
      });
    } else if (step == 'ok') {
      await serve(process);
    }
    return process;
  }

  /// A daemon this test started without the supervisor.
  Future<FakeProcess> external({String? versionOverride}) async {
    final process = FakeProcess(_nextPid++);
    _live.add(process);
    await serve(process, versionOverride: versionOverride);
    return process;
  }

  Future<void> serve(FakeProcess process, {String? versionOverride}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    process.server = server;
    final v = versionOverride ?? version;
    server.listen((r) async {
      if (r.uri.path == '/v1/health') {
        r.response.write(jsonEncode({'status': 'ok', 'version': v}));
      } else if (r.uri.path == '/v1/system/shutdown' &&
          r.headers.value('authorization') == 'Bearer $token') {
        shutdowns.add(v);
        r.response.statusCode = 202;
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 30),
            () => process.exit(0),
          ),
        );
      } else {
        r.response.statusCode = 404;
      }
      await r.response.close();
    });
    File('$home/config/runtime.json').writeAsStringSync(
      jsonEncode({
        'pid': process.pid,
        'address': '127.0.0.1:${server.port}',
        'url': 'http://127.0.0.1:${server.port}',
        'version': v,
        'apiVersion': 1,
      }),
    );
  }

  Future<void> dispose() async {
    for (final p in _live) {
      p.exit(0);
    }
  }
}

class FakeProcess implements DaemonProcess {
  FakeProcess(this.pid);

  @override
  final int pid;

  HttpServer? server;
  final _exit = Completer<int>();
  final _lines = StreamController<String>.broadcast();
  bool terminated = false;
  bool killed = false;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  Stream<String> get errorLines => _lines.stream;

  void say(String line) => _lines.add(line);

  /// The process ends (a crash when the supervisor did not ask for it).
  void exit(int code) {
    unawaited(server?.close(force: true));
    server = null;
    if (!_exit.isCompleted) _exit.complete(code);
  }

  @override
  void terminate({bool force = false}) {
    if (force) {
      killed = true;
    } else {
      terminated = true;
    }
    exit(force ? 137 : 143);
  }
}
