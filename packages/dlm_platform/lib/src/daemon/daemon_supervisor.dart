import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'runtime_info.dart';

/// A started daemon process.
abstract interface class DaemonProcess {
  /// Process id.
  int get pid;

  /// Completes with the exit code when the process ends.
  Future<int> get exitCode;

  /// Lines the process writes to standard error (its start-up complaints).
  Stream<String> get errorLines;

  /// Asks the process to end; [force] kills it.
  void terminate({bool force = false});
}

/// Starts the daemon executable.
typedef DaemonLauncher = Future<DaemonProcess> Function(
  String executable,
  List<String> arguments,
);

/// The launcher that really starts a process.
Future<DaemonProcess> launchProcess(
  String executable,
  List<String> arguments,
) async {
  final process = await Process.start(executable, arguments);
  // The daemon logs to files; drain stdout so a full pipe never blocks it.
  unawaited(process.stdout.drain<void>());
  return _IoDaemonProcess(process);
}

class _IoDaemonProcess implements DaemonProcess {
  _IoDaemonProcess(this._process)
    : errorLines = _process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .asBroadcastStream();

  final Process _process;

  @override
  final Stream<String> errorLines;

  @override
  int get pid => _process.pid;

  @override
  Future<int> get exitCode => _process.exitCode;

  @override
  void terminate({bool force = false}) {
    _process.kill(force ? ProcessSignal.sigkill : ProcessSignal.sigterm);
  }
}

/// Where the managed daemon is in its life.
enum DaemonPhase {
  /// Not running and not meant to be.
  stopped,

  /// Being started or adopted.
  starting,

  /// Serving.
  running,

  /// It stopped unexpectedly; a new one starts after a pause.
  restarting,

  /// It cannot be kept running; see [DaemonStatus.reason].
  failed,
}

/// A snapshot of the managed daemon.
class DaemonStatus {
  /// Creates a status.
  const DaemonStatus(
    this.phase, {
    this.info,
    this.reason,
    this.crashes = 0,
    this.adopted = false,
  });

  /// The phase.
  final DaemonPhase phase;

  /// Address and version, while [DaemonPhase.running].
  final RuntimeInfo? info;

  /// Why it is [DaemonPhase.restarting] or [DaemonPhase.failed]: the exit code
  /// and the last lines it printed. Contains no secrets.
  final String? reason;

  /// How many times it stopped unexpectedly since [DaemonSupervisor.start].
  final int crashes;

  /// Whether the daemon was already running and was taken over, not started.
  final bool adopted;

  @override
  String toString() => 'DaemonStatus(${phase.name}, $info, $reason)';
}

/// How often a crashing daemon is restarted.
class RestartPolicy {
  /// Creates a policy.
  const RestartPolicy({
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.maxCrashes = 5,
    this.window = const Duration(minutes: 2),
  });

  /// Pause before the first restart; doubles per consecutive crash.
  final Duration initialDelay;

  /// Longest pause.
  final Duration maxDelay;

  /// Crashes within [window] after which the supervisor gives up.
  final int maxCrashes;

  /// The period [maxCrashes] counts in.
  final Duration window;
}

/// Starts, watches and stops the `dlm` daemon of this app.
///
/// * runs `dlm serve --home <home> --address 127.0.0.1:0` and learns the real
///   port from the daemon's `runtime.json`;
/// * takes over a daemon that already runs for the same home (a second app
///   instance, or one kept running when the app quit) instead of fighting it;
/// * restarts it after a crash with growing pauses, and reports why;
/// * replaces a running daemon of another version than [expectedVersion]
///   (the app was updated);
/// * stops it gracefully through the API, or leaves it running.
class DaemonSupervisor {
  /// Creates a supervisor for the daemon at [executable] with data in [home].
  DaemonSupervisor({
    required this.executable,
    required this.home,
    this.expectedVersion,
    this.restartPolicy = const RestartPolicy(),
    this.startTimeout = const Duration(seconds: 20),
    this.stopTimeout = const Duration(seconds: 10),
    this.pollInterval = const Duration(milliseconds: 100),
    this.watchInterval = const Duration(seconds: 2),
    DaemonLauncher launcher = launchProcess,
    DateTime Function() now = DateTime.now,
  }) : _launch = launcher,
       _now = now;

  /// The daemon executable.
  final String executable;

  /// The daemon's `--home` directory.
  final String home;

  /// The daemon version this app ships with; a running daemon of another
  /// version is replaced. Null accepts any.
  final String? expectedVersion;

  /// Crash handling.
  final RestartPolicy restartPolicy;

  /// How long a new daemon may take to become healthy.
  final Duration startTimeout;

  /// How long a graceful stop may take before the process is terminated.
  final Duration stopTimeout;

  /// Polling interval while waiting.
  final Duration pollInterval;

  /// How often a running daemon is checked for a new address or silence.
  final Duration watchInterval;

  final DaemonLauncher _launch;
  final DateTime Function() _now;

  final _status = StreamController<DaemonStatus>.broadcast();
  DaemonStatus _current = const DaemonStatus(DaemonPhase.stopped);
  DaemonProcess? _process;
  Timer? _restartTimer;
  Timer? _adoptedWatch;
  final _crashTimes = <DateTime>[];
  var _wanted = false;
  var _generation = 0;

  /// Status changes.
  Stream<DaemonStatus> get status => _status.stream;

  /// The current status.
  DaemonStatus get current => _current;

  void _set(DaemonStatus s) {
    _current = s;
    if (!_status.isClosed) _status.add(s);
  }

  /// The token of the daemon, once it has created it.
  String? token() {
    try {
      final t = File(RuntimeInfo.tokenPath(home)).readAsStringSync().trim();
      return t.isEmpty ? null : t;
    } on FileSystemException {
      return null;
    }
  }

  /// Takes over or starts the daemon. Completes when it is serving or has
  /// failed; check [current].
  Future<void> start() async {
    if (_wanted) return;
    _wanted = true;
    _crashTimes.clear();
    final gen = ++_generation;
    _set(const DaemonStatus(DaemonPhase.starting));
    await _bringUp(gen);
  }

  /// Stops and starts again (for example after changing boot configuration).
  Future<void> restart() async {
    await stop();
    await start();
  }

  /// Stops the daemon gracefully and stops supervising.
  Future<void> stop() async {
    _wanted = false;
    _generation++;
    _restartTimer?.cancel();
    _adoptedWatch?.cancel();
    final info = _current.info;
    final process = _process;
    _process = null;
    if (info != null) await _shutdown(info, process);
    _set(const DaemonStatus(DaemonPhase.stopped));
  }

  /// Releases the supervisor. With [stopDaemon] false the daemon keeps
  /// running (the next app start takes it over).
  Future<void> dispose({bool stopDaemon = true}) async {
    if (stopDaemon) {
      await stop();
    } else {
      _wanted = false;
      _generation++;
      _restartTimer?.cancel();
      _adoptedWatch?.cancel();
    }
    await _status.close();
  }

  // ---- bring-up ------------------------------------------------------

  Future<void> _bringUp(int gen) async {
    final existing = await _healthyDaemon();
    if (gen != _generation) return;
    if (existing != null) {
      if (expectedVersion != null && existing.version != expectedVersion) {
        // The app was updated: replace the older daemon.
        await _shutdown(existing, null);
        if (gen != _generation) return;
      } else {
        _adopt(existing, gen);
        return;
      }
    }
    await _spawn(gen);
  }

  void _adopt(RuntimeInfo info, int gen) {
    _set(
      DaemonStatus(
        DaemonPhase.running,
        info: info,
        adopted: true,
        crashes: _crashTimes.length,
      ),
    );
    _watch(gen, adopted: true);
  }

  /// Follows the daemon while it runs: when it restarts itself (the API's
  /// restart-daemon re-executes the process, keeping its pid) its address
  /// changes, so the status is refreshed from `runtime.json`; a daemon we did
  /// not start also has no exit code to wait for, so silence means it died.
  void _watch(int gen, {required bool adopted}) {
    var misses = 0;
    _adoptedWatch?.cancel();
    _adoptedWatch = Timer.periodic(watchInterval, (timer) async {
      if (gen != _generation) return timer.cancel();
      final current = _current.info;
      if (current == null) return;
      final fresh = RuntimeInfo.read(home);
      if (fresh != null && fresh.url != current.url && await _healthy(fresh)) {
        misses = 0;
        _set(
          DaemonStatus(
            DaemonPhase.running,
            info: fresh,
            adopted: _current.adopted,
            crashes: _crashTimes.length,
          ),
        );
        return;
      }
      if (!adopted) return; // an owned process reports its own exit
      misses = await _healthy(current) ? 0 : misses + 1;
      if (misses >= 3) {
        timer.cancel();
        await _onUnexpectedEnd(gen, 'the daemon stopped answering');
      }
    });
  }

  Future<void> _spawn(int gen) async {
    final args = ['serve', '--home', home, '--address', '127.0.0.1:0'];
    final tail = <String>[];
    DaemonProcess process;
    try {
      process = await _launch(executable, args);
    } on Object catch (e) {
      _fail(gen, 'the daemon could not be started: $e');
      return;
    }
    _process = process;
    final lines = process.errorLines.listen((l) {
      tail.add(l);
      if (tail.length > 12) tail.removeAt(0);
    });
    var exited = false;
    int? code;
    unawaited(
      process.exitCode.then((c) {
        exited = true;
        code = c;
      }),
    );

    final deadline = _now().add(startTimeout);
    RuntimeInfo? info;
    while (_now().isBefore(deadline) && gen == _generation) {
      if (exited) break;
      final candidate = RuntimeInfo.read(home);
      if (candidate != null &&
          candidate.pid == process.pid &&
          await _healthy(candidate)) {
        info = candidate;
        break;
      }
      await Future<void>.delayed(pollInterval);
    }
    if (gen != _generation) {
      await lines.cancel();
      return;
    }
    if (info != null) {
      _set(
        DaemonStatus(
          DaemonPhase.running,
          info: info,
          crashes: _crashTimes.length,
        ),
      );
      _watch(gen, adopted: false);
      unawaited(
        process.exitCode.then((c) async {
          await lines.cancel();
          if (gen == _generation && _wanted) {
            await _onProcessEnded(gen, c, List.of(tail));
          }
        }),
      );
      return;
    }
    await lines.cancel();
    if (!exited) {
      process.terminate(force: true);
      _fail(
        gen,
        'the daemon did not become ready in ${startTimeout.inSeconds} s',
      );
      return;
    }
    // It ended while starting. Another daemon may hold the lock: take over.
    final other = await _healthyDaemon();
    if (other != null && gen == _generation) {
      _adopt(other, gen);
      return;
    }
    await _onProcessEnded(gen, code ?? -1, List.of(tail));
  }

  /// The daemon of this home that answers, if any.
  Future<RuntimeInfo?> _healthyDaemon() async {
    final info = RuntimeInfo.read(home);
    if (info == null) return null;
    return await _healthy(info) ? info : null;
  }

  Future<bool> _healthy(RuntimeInfo info) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final req = await client
          .getUrl(Uri.parse('${info.url}/v1/health'))
          .timeout(const Duration(seconds: 3));
      final res = await req.close().timeout(const Duration(seconds: 3));
      await res.drain<void>();
      return res.statusCode == 200;
    } on Object {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  // ---- failures ------------------------------------------------------

  Future<void> _onProcessEnded(int gen, int code, List<String> tail) {
    final said = tail.isEmpty ? '' : ': ${tail.join(' | ')}';
    return _onUnexpectedEnd(
      gen,
      'the daemon exited with code $code$said',
      // Only a clean exit can be restart-daemon handing over to a successor.
      lookForSuccessor: code == 0,
    );
  }

  Future<void> _onUnexpectedEnd(
    int gen,
    String reason, {
    bool lookForSuccessor = true,
  }) async {
    if (gen != _generation || !_wanted) return;
    _adoptedWatch?.cancel();
    _process = null;
    // `restart-daemon` replaces the process (Windows) or re-executes it
    // (elsewhere): look for the daemon that took over before calling it a crash.
    final successor = lookForSuccessor
        ? await _waitForDaemon(const Duration(seconds: 3))
        : null;
    if (gen != _generation) return;
    if (successor != null) {
      _adopt(successor, gen);
      return;
    }
    final now = _now();
    _crashTimes
      ..add(now)
      ..removeWhere((t) => now.difference(t) > restartPolicy.window);
    if (_crashTimes.length >= restartPolicy.maxCrashes) {
      _fail(
        gen,
        '$reason (it stopped ${_crashTimes.length} times in '
        '${restartPolicy.window.inMinutes} min; not restarting)',
      );
      return;
    }
    final delay = _backoff(_crashTimes.length);
    _set(
      DaemonStatus(
        DaemonPhase.restarting,
        reason: reason,
        crashes: _crashTimes.length,
      ),
    );
    _restartTimer?.cancel();
    _restartTimer = Timer(delay, () {
      if (gen == _generation && _wanted) unawaited(_spawn(gen));
    });
  }

  Duration _backoff(int crashes) {
    final micros =
        restartPolicy.initialDelay.inMicroseconds *
        math.pow(2, math.max(0, crashes - 1));
    return Duration(
      microseconds: math.min(
        micros.toInt(),
        restartPolicy.maxDelay.inMicroseconds,
      ),
    );
  }

  Future<RuntimeInfo?> _waitForDaemon(Duration within) async {
    final deadline = _now().add(within);
    while (_now().isBefore(deadline)) {
      final d = await _healthyDaemon();
      if (d != null) return d;
      await Future<void>.delayed(pollInterval);
    }
    return null;
  }

  void _fail(int gen, String reason) {
    if (gen != _generation) return;
    _wanted = false;
    _set(
      DaemonStatus(
        DaemonPhase.failed,
        reason: reason,
        crashes: _crashTimes.length,
      ),
    );
  }

  // ---- stopping ------------------------------------------------------

  Future<void> _shutdown(RuntimeInfo info, DaemonProcess? process) async {
    final t = token();
    if (t != null) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 2);
      try {
        final req = await client
            .postUrl(Uri.parse('${info.url}/v1/system/shutdown'))
            .timeout(const Duration(seconds: 3));
        req.headers.set('Authorization', 'Bearer $t');
        final res = await req.close().timeout(const Duration(seconds: 3));
        await res.drain<void>();
      } on Object {
        // Fall through to waiting and terminating.
      } finally {
        client.close(force: true);
      }
    }
    final deadline = _now().add(stopTimeout);
    while (_now().isBefore(deadline)) {
      if (!await _healthy(info)) {
        if (process == null) return;
        // Give the process a moment to exit after its API went away.
        final exited = await process.exitCode
            .then((_) => true)
            .timeout(const Duration(seconds: 2), onTimeout: () => false);
        if (exited) return;
        break;
      }
      await Future<void>.delayed(pollInterval);
    }
    process?.terminate();
    if (process != null) {
      final ended = await process.exitCode
          .then((_) => true)
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      if (!ended) process.terminate(force: true);
    }
  }
}
