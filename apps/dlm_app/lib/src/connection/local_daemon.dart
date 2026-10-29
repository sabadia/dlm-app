import 'dart:async';

import 'package:dlm_platform/dlm_platform.dart';

/// The bundled daemon as the connection layer needs it. Behind an interface so
/// the connection logic is tested without a process.
abstract interface class LocalDaemon {
  /// Starts the daemon (or adopts a running one) and completes with the first
  /// settled status: [DaemonPhase.running] with its address, or
  /// [DaemonPhase.failed] with a reason.
  Future<DaemonStatus> ensureRunning();

  /// The access token the daemon wrote, or null.
  String? token();

  /// Restarts the daemon process.
  Future<void> restart();

  /// Status changes (restarts, crashes).
  Stream<DaemonStatus> get status;

  /// Stops it when the app quits.
  Future<void> dispose();
}

/// [LocalDaemon] over the real [DaemonSupervisor].
class SupervisedDaemon implements LocalDaemon {
  /// Wraps [supervisor].
  SupervisedDaemon(this.supervisor);

  /// The supervisor that owns the process.
  final DaemonSupervisor supervisor;

  static bool _settled(DaemonStatus s) =>
      s.phase == DaemonPhase.running || s.phase == DaemonPhase.failed;

  @override
  Future<DaemonStatus> ensureRunning() async {
    final settled = supervisor.status.firstWhere(_settled);
    await supervisor.start();
    if (_settled(supervisor.current)) {
      unawaited(settled.then((_) {}, onError: (Object _) {}));
      return supervisor.current;
    }
    return settled;
  }

  @override
  String? token() => supervisor.token();

  @override
  Future<void> restart() => supervisor.restart();

  @override
  Stream<DaemonStatus> get status => supervisor.status;

  @override
  Future<void> dispose() => supervisor.dispose();
}

/// Stands in when the bundled daemon binary cannot be found, so the app shows
/// why instead of crashing.
class MissingDaemon implements LocalDaemon {
  /// Creates the stand-in with the paths that were tried.
  MissingDaemon(this.tried);

  /// The locations that were searched.
  final List<String> tried;

  @override
  Future<DaemonStatus> ensureRunning() async => DaemonStatus(
    DaemonPhase.failed,
    reason: 'the dlm daemon was not found (looked in ${tried.join(', ')})',
  );

  @override
  String? token() => null;

  @override
  Future<void> restart() async {}

  @override
  Stream<DaemonStatus> get status => const Stream.empty();

  @override
  Future<void> dispose() async {}
}
