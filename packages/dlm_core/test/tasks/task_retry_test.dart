import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

void main() {
  Task failed({TaskRetry? retry}) => task('t', status: 'error').copyWith(
    error: TaskError(
      at: DateTime.utc(2026, 11, 5),
      code: 'network',
      message: 'connection reset',
      retryable: true,
      retry: retry,
    ),
  );

  test('a failed task with a retry due is waiting, not given up', () {
    final due = DateTime.utc(2026, 11, 5, 12);
    final t = failed(retry: TaskRetry(attempt: 2, max: 3, nextAt: due));
    expect(t.isWaitingForRetry, isTrue);
    expect(t.hasGivenUp, isFalse);
    expect(t.retryAt, due);
  });

  test('a failed task without a retry has given up', () {
    final t = failed();
    expect(t.isWaitingForRetry, isFalse);
    expect(t.hasGivenUp, isTrue);
    expect(t.retryAt, isNull);
  });

  test('only a running torrent with all its data is seeding', () {
    Task t({String engine = 'bt', String status = 'running', int done = 100}) =>
        task('b', status: status, downloaded: done, engine: engine);
    expect(t().isSeeding, isTrue);
    expect(t(engine: 'http').isSeeding, isFalse, reason: 'not a torrent');
    expect(t(done: 40).isSeeding, isFalse, reason: 'still downloading');
    expect(t(status: 'paused').isSeeding, isFalse, reason: 'paused');
  });

  test('retrying all failed marks them queued and clears the error', () async {
    final repo = FakeTaskRepository();
    final store = TaskStore();
    addTearDown(store.dispose);
    store.tasks
      ..put('a', failed())
      ..put('run', task('run', status: 'running'));
    final results = await TaskActions(repo, store).retryFailed();
    expect(results, isEmpty);
    expect(repo.calls, ['retryFailed']);
    expect(store.tasks['a']!.statusKind, TaskStatus.queued);
    expect(store.tasks['a']!.error, isNull);
    expect(store.tasks['run']!.statusKind, TaskStatus.running);
  });

  test('stop seeding calls the daemon for that task', () async {
    final repo = FakeTaskRepository();
    final store = TaskStore();
    addTearDown(store.dispose);
    repo.tasks.add(task('b', status: 'running'));
    store.tasks.put('b', task('b', status: 'running'));
    await TaskActions(repo, store).stopSeeding('b');
    expect(repo.calls, ['stopSeeding:b']);
  });
}
