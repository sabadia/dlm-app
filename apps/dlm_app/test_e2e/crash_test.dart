@Tags(['e2e'])
library;

import 'dart:io' as io;
import 'dart:io' show HttpOverrides;

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'e2e_support.dart';

/// A daemon that is killed is noticed and replaced, its data is still there,
/// and a client of the dead one fails fast instead of hanging.
void main() {
  final binary = daemonBinary();
  final skip = binary == null ? 'no daemon binary (DLM_DAEMON)' : null;

  test(
    'a killed daemon is restarted with its data, and the old address fails '
    'fast',
    () async {
      HttpOverrides.global = null;
      final home = io.Directory.systemTemp.createTempSync('dlm_crash_').path;
      final files = await FileServer.start();
      final downloads = io.Directory.systemTemp.createTempSync('dlm_crash_dl_');
      final supervisor = DaemonSupervisor(
        executable: binary!,
        home: home,
        restartPolicy: const RestartPolicy(
          initialDelay: Duration(milliseconds: 200),
        ),
        watchInterval: const Duration(milliseconds: 200),
      );
      addTearDown(() async {
        await supervisor.dispose();
        await files.stop();
        downloads.deleteSync(recursive: true);
        try {
          io.Directory(home).deleteSync(recursive: true);
        } on io.FileSystemException {
          // Let go in its own time.
        }
      });

      await supervisor.start();
      final first = supervisor.current.phase == DaemonPhase.running
          ? supervisor.current
          : await supervisor.status.firstWhere(
              (s) => s.phase == DaemonPhase.running,
            );
      final api = DlmApi(
        DlmEndpoint(baseUrl: first.info!.url, token: supervisor.token()),
      );
      final made = await guard(
        () => api.rest.tasks.createTask(
          body: CreateTaskBody(
            url: files.url('/fast.bin'),
            dir: downloads.path,
            paused: true,
          ),
        ),
      );

      io.Process.killPid(first.info!.pid, io.ProcessSignal.sigkill);

      final second = await supervisor.status
          .firstWhere(
            (s) =>
                s.phase == DaemonPhase.running &&
                s.info != null &&
                s.info!.pid != first.info!.pid,
          )
          .timeout(const Duration(seconds: 40));
      expect(second.crashes, greaterThanOrEqualTo(1));

      final fresh = DlmApi(
        DlmEndpoint(baseUrl: second.info!.url, token: supervisor.token()),
      );
      final page = await guard(() => fresh.rest.tasks.listTasks());
      expect(
        (page.tasks ?? const []).map((t) => t.id),
        contains(made.id),
        reason: 'the task survived the crash',
      );

      if (second.info!.url != first.info!.url) {
        await expectLater(
          guard(() => api.rest.tasks.listTasks())
              .timeout(const Duration(seconds: 10)),
          throwsA(isA<ApiConnectionFailure>()),
        );
      }
    },
    skip: skip,
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
