import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeTaskRepository()
      ..tasks.addAll([for (var i = 0; i < 5; i++) task('t$i', position: i)]);
    container = ProviderContainer.test(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        listRefreshDelayProvider.overrideWithValue(
          const Duration(milliseconds: 20),
        ),
      ],
    );
  });

  const query = TaskQuery();
  TaskListState listState() => container.read(taskListProvider(query));

  Future<void> settle([int ms = 60]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('loads the first page, then more on demand', () async {
    container.listen(taskListProvider(query), (_, _) {});
    await settle();
    expect(listState().loaded, isTrue);
    expect(listState().ids, ['t0', 't1']);
    expect(listState().hasMore, isTrue);
    final store = container.read(taskStoreProvider);
    expect(store.tasks['t1'], isNotNull, reason: 'pages fill the entity cache');

    await container.read(taskListProvider(query).notifier).loadMore();
    await container.read(taskListProvider(query).notifier).loadMore();
    expect(listState().ids, ['t0', 't1', 't2', 't3', 't4']);
    expect(listState().hasMore, isFalse);
    await container.read(taskListProvider(query).notifier).loadMore();
    expect(
      repo.calls.where((c) => c.startsWith('list')).length,
      3,
      reason: 'no request past the end',
    );
  });

  test('a filtered query asks for its own tasks', () async {
    repo.tasks[1] = task('t1', status: 'running');
    const running = TaskQuery(statuses: {TaskStatus.running});
    container.listen(taskListProvider(running), (_, _) {});
    await settle();
    expect(container.read(taskListProvider(running)).ids, ['t1']);
  });

  test('a failure is reported and a retry recovers', () async {
    repo.failNext = const ApiConnectionFailure('daemon down');
    container.listen(taskListProvider(query), (_, _) {});
    await settle();
    expect(listState().error, isA<ApiConnectionFailure>());
    expect(listState().loaded, isFalse);
    await container.read(taskListProvider(query).notifier).loadFirst();
    expect(listState().error, isNull);
    expect(listState().loaded, isTrue);
  });

  test('a burst of membership events re-reads the window once', () async {
    container.listen(taskListProvider(query), (_, _) {});
    await settle();
    await container.read(taskListProvider(query).notifier).loadMore();
    final before = repo.calls.length;
    repo.tasks.add(task('t5', position: 5));

    final store = container.read(taskStoreProvider);
    for (var i = 0; i < 10; i++) {
      store.apply(
        StreamEvent.fromJson({
          'id': i,
          'type': 'task.created',
          'taskId': 'x$i',
          'time': '2026-10-30T10:00:00Z',
          'data': {
            'createdAt': '2026-10-29T00:00:00Z',
            'downloaded': 0,
            'id': 'x$i',
            'position': 9,
            'priority': 'normal',
            'queueId': 'main',
            'settings': <String, Object?>{},
            'size': 1,
            'source': {
              'currentUrl': 'http://x',
              'fingerprint': {'size': 1},
            },
            'status': 'queued',
            'updatedAt': '2026-10-29T00:00:00Z',
          },
        }),
      );
    }
    await settle(120);
    final reads = repo.calls
        .skip(before)
        .where((c) => c.startsWith('list'))
        .length;
    expect(
      reads,
      inInclusiveRange(1, 2),
      reason: 'debounced, not one per event (at most two pages)',
    );
    expect(listState().ids, containsAll(['t0', 't1', 't2', 't3']));
  });

  test(
    'disposing while a request runs does not touch the dead state',
    () async {
      container.listen(taskListProvider(query), (_, _) {}).close();
      container.dispose();
      await settle(); // would throw "bad state" if the late answer wrote state
    },
  );

  test('one task provider wakes only for its own task', () async {
    final store = container.read(taskStoreProvider);
    store.tasks
      ..put('a', task('a'))
      ..put('b', task('b'));
    var aBuilds = 0;
    container.listen(taskProvider('a'), (_, _) => aBuilds++);
    store.tasks.put('b', task('b', status: 'paused'));
    await settle(10);
    expect(aBuilds, 0);
    store.tasks.put('a', task('a', status: 'running'));
    await settle(10);
    expect(aBuilds, 1);
    expect(container.read(taskProvider('a'))!.statusKind, TaskStatus.running);
  });
}
