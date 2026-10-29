import 'dart:convert';
import 'dart:io';

import '../login_item.dart';

/// What `dlm service status` reports.
class DaemonServiceStatus {
  /// Creates the status.
  const DaemonServiceStatus({
    required this.kind,
    required this.installed,
    required this.active,
    this.path,
  });

  /// Decodes the JSON the daemon prints; null when it is not a status.
  static DaemonServiceStatus? fromJson(Object? raw) {
    if (raw is! Map<String, Object?>) return null;
    final kind = raw['kind'];
    final installed = raw['installed'];
    final active = raw['active'];
    if (kind is! String || installed is! bool || active is! bool) return null;
    final path = raw['path'];
    return DaemonServiceStatus(
      kind: kind,
      installed: installed,
      active: active,
      path: path is String ? path : null,
    );
  }

  /// `launchd`, `systemd` or `registry`.
  final String kind;

  /// Whether the login item exists.
  final bool installed;

  /// Whether the system has it loaded or enabled too.
  final bool active;

  /// The plist, unit file or registry key.
  final String? path;
}

/// Runs a program and returns what it printed; behind a function so tests do
/// not start processes.
typedef ProcessRun = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
);

Future<ProcessResult> _startProcess(
  String executable,
  List<String> arguments,
) => Process.run(executable, arguments);

/// The daemon's own login item (`dlm service`): it keeps downloads running
/// with no app open, separately from the app's own [LoginItem].
class DaemonService {
  /// Creates the control for the daemon at [executable]; [run] exists for
  /// tests. [home] is the `--home` the daemon is started with, so the login
  /// item runs the same daemon the app manages.
  DaemonService({
    required this.executable,
    this.home,
    ProcessRun run = _startProcess,
  }) : _run = run;

  /// The `dlm` binary.
  final String executable;

  /// The daemon's home directory, when it is not the default.
  final String? home;

  final ProcessRun _run;

  List<String> _args(String verb) => [
    if (home != null) ...['--home', home!],
    'service',
    verb,
    '--output',
    'json',
  ];

  Future<DaemonServiceStatus> _call(String verb) async {
    final ProcessResult result;
    try {
      result = await _run(executable, _args(verb));
    } on ProcessException catch (e) {
      throw LoginItemException(e.message);
    }
    final out = result.stdout.toString().trim();
    DaemonServiceStatus? status;
    try {
      status = out.isEmpty
          ? null
          : DaemonServiceStatus.fromJson(jsonDecode(out));
    } on FormatException {
      status = null;
    }
    if (result.exitCode != 0 || status == null) {
      final err = result.stderr.toString().trim();
      throw LoginItemException(
        err.isNotEmpty ? err : 'dlm service $verb failed (${result.exitCode})',
      );
    }
    return status;
  }

  /// Whether the daemon starts at login.
  Future<DaemonServiceStatus> status() => _call('status');

  /// Installs the login item and starts the daemon through it.
  Future<DaemonServiceStatus> install() => _call('install');

  /// Removes the login item.
  Future<DaemonServiceStatus> uninstall() => _call('uninstall');
}
