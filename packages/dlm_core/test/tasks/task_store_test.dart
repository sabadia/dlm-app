import 'dart:async';
import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

StreamEvent statusEvent(
  String id,
  String from,
  String to, {
  TaskError? error,
}) => StreamEvent.fromJson({
  'id': 1,
  'type': 'task.status',
  'taskId': id,
  'time': '2026-10-30T10:00:00Z',
  'data': {
    'from': from,
    'to': to,
    if (error != null) 'error': jsonDecode(jsonEncode(error)),
  },
});

StreamEvent progressEvent(String id, int downloaded) => StreamEvent.fromJson({
  'id': 2,
  'type': 'task.progress',
  'taskId': id,
  'time': '2026-10-30T10:00:01Z',
  'data': {'downloaded': downloaded, 'size': 100, 'speed': 5, 'connections': 1},
});

StreamEvent taskEvent(String type, Task t) => StreamEvent.fromJson({
  'id': 3,
  'type': type,
  'taskId': t.id,
  'time': '2026-10-30T10:00:02Z',
  'data': jsonDecode(jsonEncode(t)),
});

void main() {
  late TaskStore store;
  setUp(() => store = TaskStore());
  tearDown(() => store.dispose());

  test('created and updated events put the task in the cache', () {
    store
      ..apply(taskEvent('task.created', task('a')))
      ..apply(taskEvent('task.updated', task('a', status: 'running')));
    expect(store.tasks['a']!.statusKind, TaskStatus.running);
    expect(store.tasks.length, 1);
  });

  test('a status event patches the cached task and clears stale progress', () {
    store.tasks.put('a', task('a', status: 'running'));
    store.progress.put('a', progress(40));
    store.apply(statusEvent('a', 'running', 'completed'));
    final t = store.tasks['a']!;
    expect(t.statusKind, TaskStatus.completed);
    expect(t.downloaded, 100, reason: 'a finished download is complete');
    expect(t.completedAt, DateTime.utc(2026, 10, 30, 10));
    expect(store.progress['a'], isNull);
  });

  test('a status event carries the failure of an errored task', () {
    store.tasks.put('a', task('a', status: 'running'));
    final err = TaskError(
      at: DateTime.utc(2026, 10, 30),
      code: 'network',
      message: 'reset',
      retryable: true,
    );
    store.apply(statusEvent('a', 'running', 'error', error: err));
    expect(store.tasks['a']!.error!.code, 'network');
    store.apply(statusEvent('a', 'error', 'queued'));
    expect(store.tasks['a']!.error, isNull, reason: 'the failure is cleared');
  });

  test('a status event for an unknown task does not invent it', () {
    store.apply(statusEvent('ghost', 'queued', 'running'));
    expect(store.tasks['ghost'], isNull);
  });

  test('progress goes to the progress cache and wakes only that task', () {
    store.tasks
      ..put('a', task('a'))
      ..put('b', task('b'));
    var a = 0;
    var b = 0;
    store.progress
      ..listen('a', () => a++)
      ..listen('b', () => b++);
    store
      ..apply(progressEvent('a', 10))
      ..apply(progressEvent('a', 20));
    expect(store.progress['a']!.downloaded, 20);
    expect((a, b), (2, 0));
  });

  test('deleting removes the task and its progress', () {
    store.tasks.put('a', task('a'));
    store.progress.put('a', progress(1));
    store.apply(taskEvent('task.deleted', task('a')));
    expect(store.tasks['a'], isNull);
    expect(store.progress['a'], isNull);
  });

  test('membership changes are announced, progress is not', () async {
    var changes = 0;
    final sub = store.membershipChanged.listen((_) => changes++);
    store
      ..apply(taskEvent('task.created', task('a')))
      ..apply(progressEvent('a', 1))
      ..apply(statusEvent('a', 'queued', 'running'))
      ..apply(taskEvent('task.deleted', task('a')));
    expect(changes, 3);
    await sub.cancel();
  });

  test('queue events keep the queue cache current', () {
    final queue = {
      'id': 'q1',
      'name': 'Q',
      'isDefault': false,
      'position': 1,
      'state': 'running',
      'settings': <String, Object?>{},
      'createdAt': '2026-10-29T00:00:00Z',
      'updatedAt': '2026-10-29T00:00:00Z',
    };
    store.apply(
      StreamEvent.fromJson({
        'id': 1,
        'type': 'queue.created',
        'time': '2026-10-30T10:00:00Z',
        'data': queue,
      }),
    );
    expect(store.queues['q1']!.name, 'Q');
    store.apply(
      StreamEvent.fromJson({
        'id': 2,
        'type': 'queue.deleted',
        'time': '2026-10-30T10:00:00Z',
        'data': queue,
      }),
    );
    expect(store.queues['q1'], isNull);
  });

  test('entity listeners are removed when disposed', () {
    var calls = 0;
    final off = store.tasks.listen('a', () => calls++);
    store.tasks.put('a', task('a'));
    off();
    store.tasks.put('a', task('a', status: 'paused'));
    expect(calls, 1);
  });

  test('a speed report is kept and announced', () async {
    final seen = <int>[];
    final sub = store.speedChanged.listen((s) => seen.add(s.down));
    store.apply(
      StreamEvent.fromJson({
        'id': 3,
        'type': 'system.speed',
        'time': '2026-10-30T10:00:03Z',
        'data': {'active': 1, 'down': 500, 'queued': 2, 'up': 7},
      }),
    );
    expect(store.speed?.down, 500);
    expect(store.speed?.queued, 2);
    expect(seen, [500]);
    await sub.cancel();
  });

  test('limit and quota events tell whoever shows them to read again', () {
    var calls = 0;
    final sub = store.limitsChanged.listen((_) => calls++);
    store
      ..apply(
        StreamEvent.fromJson({
          'id': 4,
          'type': 'limits.changed',
          'time': '2026-10-30T10:00:04Z',
          'data': {'speedLimit': 0},
        }),
      )
      ..apply(
        StreamEvent.fromJson({
          'id': 5,
          'type': 'quota.reset',
          'time': '2026-10-30T10:00:05Z',
          'data': {
            'bytes': 100,
            'period': 'month',
            'scope': 'global',
            'used': 0,
          },
        }),
      );
    expect(calls, 2);
    unawaited(sub.cancel());
  });
}
