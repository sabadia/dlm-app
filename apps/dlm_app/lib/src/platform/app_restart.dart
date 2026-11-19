import 'dart:async';
import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../about/diagnostics_providers.dart';
import '../connection/connection_controller.dart';
import '../shell/feedback.dart';
import 'startup.dart';

/// Whether a saved setting asked for a restart that has not happened yet.
class RestartNeededNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Marks (or clears) the need.
  void mark({required bool needed}) => state = needed;
}

/// Whether the app should offer to restart (see [RestartNeededNotifier]).
final restartNeededProvider = NotifierProvider<RestartNeededNotifier, bool>(
  RestartNeededNotifier.new,
);

/// Single-quotes [s] for a POSIX shell.
String _sh(String s) => "'${s.replaceAll("'", r"'\''")}'";

/// The shell command that waits for this process to exit and then starts the
/// app again. Run detached, it outlives the app.
({String exe, List<String> args}) relaunchCommand({
  required int pid,
  required String executable,
  required String operatingSystem,
}) {
  if (operatingSystem == 'windows') {
    final script =
        'Wait-Process -Id $pid -ErrorAction SilentlyContinue; '
        "Start-Process -FilePath '${executable.replaceAll("'", "''")}'";
    return (
      exe: 'powershell',
      args: ['-NoProfile', '-WindowStyle', 'Hidden', '-Command', script],
    );
  }
  // On macOS the bundle is opened (so the system starts it like the user
  // does); a bare executable (a development run) is started directly.
  var launch = _sh(executable);
  if (operatingSystem == 'macos') {
    final i = executable.indexOf('.app/Contents/MacOS/');
    if (i > 0) launch = 'open -n ${_sh(executable.substring(0, i + 4))}';
  }
  final script = 'while kill -0 $pid 2>/dev/null; do sleep 0.2; done; $launch';
  return (exe: '/bin/sh', args: ['-c', script]);
}

/// Restarts the whole app: the daemon is restarted (so it reads what was
/// saved), a helper process is started that opens the app again once this one
/// has exited, and the app quits.
Future<void> restartApp(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  try {
    final service = ref.read(daemonServiceStatusProvider).value;
    if (ref.read(activeProfileProvider).isLocal) {
      // A daemon kept running by its login item outlives the app, so it is
      // restarted here; one the app started stops with it.
      if (service?.installed ?? false) {
        await ref.read(localDaemonProvider).restart();
      }
    } else {
      await ref.read(daemonRepositoryProvider).restart();
    }
    final cmd = relaunchCommand(
      pid: pid,
      executable: Platform.resolvedExecutable,
      operatingSystem: Platform.operatingSystem,
    );
    await Process.start(cmd.exe, cmd.args, mode: ProcessStartMode.detached);
    await ref
        .read(localDaemonProvider)
        .dispose(keepRunning: service?.installed ?? false);
    await ref.read(windowControlProvider).quit();
  } on Object catch (e) {
    if (context.mounted) {
      showNotice(context, ref, l.restart_failed, tone: DlmTone.danger);
      ref.read(appLoggerProvider).warning('restarting the app failed: $e');
    }
  }
}
