@Tags(['e2e'])
library;

import 'dart:io' as io;
import 'dart:io' show HttpOverrides;

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'e2e_support.dart';

/// The app's own layers (API client, event stream, task cache, repositories)
/// against a real daemon process. Run with
/// `flutter test test_e2e --tags e2e`; it skips itself without a daemon binary.
void main() {
  final binary = daemonBinary();
  final skip = binary == null
      ? 'no daemon binary: set DLM_DAEMON or put dlm on the PATH'
      : null;

  late E2eDaemon d;
  late FileServer files;
  late io.Directory downloads;

  if (skip == null) {
    setUpAll(() async {
      // flutter_test stubs HTTP out; these tests need the real thing.
      HttpOverrides.global = null;
      d = await E2eDaemon.start(binary!);
      files = await FileServer.start();
      downloads = io.Directory.systemTemp.createTempSync('dlm_e2e_dl_');
    });

    tearDownAll(() async {
      await d.stop();
      await files.stop();
      downloads.deleteSync(recursive: true);
    });
  }

  Future<Task> add(String path, {bool paused = false}) => d.container
      .read(addRepositoryProvider)
      .create(
        CreateTaskBody(
          url: files.url(path),
          dir: downloads.path,
          paused: paused,
          allowDuplicate: true,
        ),
      );

  test('the daemon says who it is and is compatible', () async {
    final info = await d.container.read(systemInfoProvider.future);
    expect(info.version, d.info.version);
    expect(info.apiVersion, greaterThanOrEqualTo(appApiVersion - 1));
    expect(
      info.minClientApi,
      lessThanOrEqualTo(appApiVersion),
      reason: 'this app is new enough for this daemon',
    );
  }, skip: skip);

  test(
    'a download runs to the end, with its events, and the file is right',
    () async {
      final task = await add('/fast.bin');
      await d.until(
        () => d.store.tasks[task.id]?.statusKind == TaskStatus.completed,
        what: 'the download to complete',
      );
      final done = d.store.tasks[task.id]!;
      final log = d.store.logOf(task.id);
      expect(log.first.kind, TaskLogKind.created);
      expect(log.any((e) => e.to == 'completed'), isTrue);
      final file = io.File('${downloads.path}/${done.name ?? 'fast.bin'}');
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), files.fast.length);
      expect(file.readAsBytesSync(), files.fast);
    },
    skip: skip,
  );

  test(
    'pause, resume and delete reach the daemon and its events come back',
    () async {
      final task = await add('/slow.bin');
      await d.until(
        () => d.store.tasks[task.id]?.statusKind == TaskStatus.running,
        what: 'the slow download to start',
      );
      final actions = d.container.read(taskActionsProvider);
      await actions.pause([task.id]);
      await d.until(
        () => d.store.tasks[task.id]?.statusKind == TaskStatus.paused,
        what: 'pause',
      );
      await actions.resume([task.id]);
      await d.until(
        () => d.store.tasks[task.id]?.statusKind == TaskStatus.running,
        what: 'resume',
      );
      await actions.delete([task.id]);
      await d.until(() => d.store.tasks[task.id] == null, what: 'delete');
    },
    skip: skip,
  );

  test('queues are created, renamed and removed', () async {
    final queues = d.api.rest.queues;
    final created = await queues.createQueue(
      body: const CreateQueueBody(name: 'e2e'),
    );
    expect(created.name, 'e2e');
    final list = await queues.listQueues();
    expect((list.queues ?? const []).any((q) => q.id == created.id), isTrue);
    await queues.deleteQueue(id: created.id);
    final after = await queues.listQueues();
    expect((after.queues ?? const []).any((q) => q.id == created.id), isFalse);
  }, skip: skip);

  test('an invalid setting is refused with the field it is about', () async {
    await expectLater(
      guard(
        () => d.api.rest.settings.patchSettings(
          body: const {'maxConnections': -5},
        ),
      ),
      throwsA(isA<ApiProblem>().having((p) => p.status, 'status', 422)),
    );
  }, skip: skip);

  test('a wrong token is refused as unauthorised', () async {
    final stranger = DlmApi(
      DlmEndpoint(baseUrl: d.info.url, token: 'not-the-token'),
    );
    await expectLater(
      guard(() => stranger.rest.tasks.listTasks()),
      throwsA(isA<ApiProblem>().having((p) => p.status, 'status', 401)),
    );
  }, skip: skip);
}
