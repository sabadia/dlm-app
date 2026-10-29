import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The daemon binary to test against: `DLM_DAEMON`, else `dlm` on the PATH.
String? daemonBinary() {
  final env = io.Platform.environment['DLM_DAEMON'];
  if (env != null && env.isNotEmpty) {
    return io.File(env).existsSync() ? env : null;
  }
  return const DaemonLocator().find();
}

/// A real daemon in a throwaway home, and a session talking to it.
class E2eDaemon {
  E2eDaemon._(
    this.supervisor,
    this.home,
    this.info,
    this.token,
    this.session,
    this.container,
  );

  /// Starts the binary and connects, the way the app does.
  static Future<E2eDaemon> start(String executable) async {
    final home = io.Directory.systemTemp.createTempSync('dlm_e2e_').path;
    final supervisor = DaemonSupervisor(executable: executable, home: home);
    await supervisor.start();
    final settled = supervisor.current.phase == DaemonPhase.running
        ? supervisor.current
        : await supervisor.status.firstWhere(
            (s) =>
                s.phase == DaemonPhase.running || s.phase == DaemonPhase.failed,
          );
    if (settled.phase != DaemonPhase.running) {
      throw StateError('the daemon did not start: ${settled.reason}');
    }
    final token = supervisor.token();
    final api = DlmApi(DlmEndpoint(baseUrl: settled.info!.url, token: token));
    final session = DlmSession.open(api);
    final container = ProviderContainer(
      overrides: [sessionProvider.overrideWithValue(session)],
    );
    container.read(syncEngineProvider).start();
    return E2eDaemon._(
      supervisor,
      home,
      settled.info!,
      token,
      session,
      container,
    );
  }

  /// The process owner.
  final DaemonSupervisor supervisor;

  /// The daemon's home directory.
  final String home;

  /// Its address and version.
  final RuntimeInfo info;

  /// The access token.
  final String? token;

  /// The session over its REST and event APIs.
  final DlmSession session;

  /// The app's providers over that session.
  final ProviderContainer container;

  /// The REST client.
  DlmApi get api => session.api;

  /// The app's cache of tasks, fed by events.
  TaskStore get store => container.read(taskStoreProvider);

  /// Stops everything and removes the files.
  Future<void> stop() async {
    container.dispose();
    await supervisor.dispose();
    try {
      io.Directory(home).deleteSync(recursive: true);
    } on io.FileSystemException {
      // The daemon may still be letting go of a file.
    }
  }

  /// Waits until [test] holds, polling every 50 ms.
  Future<void> until(
    bool Function() test, {
    Duration timeout = const Duration(seconds: 30),
    String? what,
  }) async {
    final end = DateTime.now().add(timeout);
    while (!test()) {
      if (DateTime.now().isAfter(end)) {
        throw TimeoutException(
          'timed out waiting for ${what ?? 'a condition'}',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// A small HTTP server of files for the daemon to download.
class FileServer {
  FileServer._(this._server);

  /// Starts on a free loopback port.
  static Future<FileServer> start() async {
    final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    final s = FileServer._(server);
    server.listen(s._serve);
    return s;
  }

  final io.HttpServer _server;

  /// Bytes served at `/fast.bin`.
  final List<int> fast = List<int>.generate(256 * 1024, (i) => i % 251);

  /// How many requests came in.
  int requests = 0;

  /// The address of [path].
  String url(String path) => 'http://127.0.0.1:${_server.port}$path';

  Future<void> _serve(io.HttpRequest request) async {
    requests++;
    final response = request.response;
    if (request.uri.path == '/fast.bin') {
      response.headers
        ..contentType = io.ContentType.binary
        ..set(io.HttpHeaders.acceptRangesHeader, 'none');
      response
        ..contentLength = fast.length
        ..add(fast);
    } else if (request.uri.path == '/slow.bin') {
      // 100 KiB a second for ten seconds: long enough to pause it.
      response.headers
        ..contentType = io.ContentType.binary
        ..set(io.HttpHeaders.acceptRangesHeader, 'none');
      response.contentLength = 1024 * 1024;
      final rng = Random(7);
      try {
        for (var i = 0; i < 10; i++) {
          response.add(List<int>.generate(100 * 1024, (_) => rng.nextInt(256)));
          await response.flush();
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      } on Object {
        // The daemon closed the connection (paused or deleted).
      }
    } else {
      response.statusCode = io.HttpStatus.notFound;
    }
    await response.close();
  }

  /// Stops the server.
  Future<void> stop() => _server.close(force: true);
}
