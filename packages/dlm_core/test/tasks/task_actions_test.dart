import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late TaskStore store;
  late TaskActions actions;

  setUp(() {
    repo = FakeTaskRepository();
    store = TaskStore();
    actions = TaskActions(repo, store);
    store.tasks
      ..put('run', task('run', status: 'running'))
      ..put('que', task('que'))
      ..put('done', task('done', status: 'completed'))
      ..put('bad', task('bad', status: 'error'));
  });
  tearDown(() => store.dispose());

  TaskStatus statusOf(String id) => store.tasks[id]!.statusKind;

  test(
    'pause flips pausable tasks at once and keeps the daemon answer',
    () async {
      final seenDuringCall = <String, TaskStatus>{};
      repo.failIds.clear();
      final future = actions.pause(['run', 'que', 'done']);
      seenDuringCall['run'] = statusOf('run');
      seenDuringCall['done'] = statusOf('done');
      final results = await future;
      expect(seenDuringCall['run'], TaskStatus.paused, reason: 'optimistic');
      expect(
        seenDuringCall['done'],
        TaskStatus.completed,
        reason: 'cannot be paused',
      );
      expect(results.every((r) => r.ok), isTrue);
      expect(statusOf('que'), TaskStatus.paused);
      expect(repo.calls, ['pause:run,que,done']);
    },
  );

  test(
    'a task the daemon refuses is put back, the others stay changed',
    () async {
      repo.failIds.add('que');
      final results = await actions.pause(['run', 'que']);
      expect(
        results.firstWhere((r) => r.id == 'que').error!.code,
        'task.invalid_state',
      );
      expect(statusOf('que'), TaskStatus.queued, reason: 'rolled back');
      expect(statusOf('run'), TaskStatus.paused);
    },
  );

  test('a failed call rolls everything back and rethrows', () async {
    repo.failNext = const ApiConnectionFailure('down');
    await expectLater(
      actions.pause(['run', 'que']),
      throwsA(isA<ApiConnectionFailure>()),
    );
    expect(statusOf('run'), TaskStatus.running);
    expect(statusOf('que'), TaskStatus.queued);
  });

  test('resume turns paused and failed tasks into queued', () async {
    store.tasks.put('p', task('p', status: 'paused'));
    final results = await actions.resume(['p', 'bad', 'run']);
    expect(results, hasLength(3));
    expect(statusOf('p'), TaskStatus.queued);
    expect(statusOf('bad'), TaskStatus.queued);
    expect(store.tasks['bad']!.error, isNull);
  });

  test(
    'delete removes tasks immediately and restores the refused ones',
    () async {
      repo.failIds.add('que');
      final results = await actions.delete(['run', 'que'], files: true);
      expect(store.tasks['run'], isNull);
      expect(store.tasks['que'], isNotNull, reason: 'the daemon refused');
      expect(results.where((r) => !r.ok).single.id, 'que');
      expect(repo.calls, ['delete:run,que:true']);
    },
  );

  test('a failed delete brings every task back', () async {
    repo.failNext = const ApiConnectionFailure('down');
    await expectLater(
      actions.delete(['run', 'que']),
      throwsA(isA<ApiFailure>()),
    );
    expect(store.tasks['run'], isNotNull);
    expect(store.tasks['que'], isNotNull);
  });

  test(
    'restart, move and reorder apply the daemon answer or roll back',
    () async {
      expect((await actions.restart('bad')).statusKind, TaskStatus.queued);
      expect(statusOf('bad'), TaskStatus.queued);
      expect((await actions.move('que', 'other')).queueId, 'other');
      expect(store.tasks['que']!.queueId, 'other');
      expect((await actions.reorder('que', 7)).position, 7);

      repo.failNext = const ApiProblem(status: 409, code: 'task.invalid_state');
      await expectLater(actions.reorder('run', 3), throwsA(isA<ApiProblem>()));
      expect(store.tasks['run']!.position, 0, reason: 'rolled back');
    },
  );
}
