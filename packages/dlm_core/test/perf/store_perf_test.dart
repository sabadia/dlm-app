import 'dart:convert';
import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

/// Performance budgets of the task cache (docs/performance.md). They are
/// deliberately loose (about ten times the target) because CI machines vary;
/// a failure means something got an order of magnitude slower.
StreamEvent createdEvent(Task t) => StreamEvent.fromJson({
  'id': 1,
  'type': 'task.created',
  'taskId': t.id,
  'time': '2026-10-30T10:00:00Z',
  'data': jsonDecode(jsonEncode(t)),
});

StreamEvent progressEvent(String id, int downloaded) => StreamEvent.fromJson({
  'id': 2,
  'type': 'task.progress',
  'taskId': id,
  'time': '2026-10-30T10:00:01Z',
  'data': {
    'downloaded': downloaded,
    'size': 1 << 30,
    'speed': 1 << 20,
    'connections': 4,
  },
});

int rssMiB() => ProcessInfo.currentRss ~/ (1024 * 1024);

void main() {
  late TaskStore store;
  setUp(() => store = TaskStore());
  tearDown(() => store.dispose());

  test('5 000 progress events are applied in under 250 ms (1 000 a second '
      'costs under 5 % of a core)', () {
    final ids = [for (var i = 0; i < 200; i++) 'task-$i'];
    for (final id in ids) {
      store.apply(createdEvent(task(id, status: 'running')));
    }
    final events = [
      for (var i = 0; i < 5000; i++) progressEvent(ids[i % ids.length], i),
    ];
    final watch = Stopwatch()..start();
    events.forEach(store.apply);
    watch.stop();
    expect(
      watch.elapsedMilliseconds,
      lessThan(250),
      reason: '${watch.elapsedMilliseconds} ms for 5 000 events',
    );
  });

  test('50 000 tasks are cached in under 5 s and found at once', () {
    final events = [for (var i = 0; i < 50000; i++) createdEvent(task('t$i'))];
    final watch = Stopwatch()..start();
    events.forEach(store.apply);
    watch.stop();
    expect(
      watch.elapsedMilliseconds,
      lessThan(5000),
      reason: '${watch.elapsedMilliseconds} ms for 50 000 tasks',
    );
    final lookup = Stopwatch()..start();
    for (var i = 0; i < 50000; i++) {
      expect(store.tasks['t$i'], isNotNull);
    }
    lookup.stop();
    expect(lookup.elapsedMilliseconds, lessThan(500));
  });

  test('10 000 tasks with progress take under 150 MiB more memory', () {
    final events = [
      for (var i = 0; i < 10000; i++)
        createdEvent(task('m$i', status: 'running', size: 1 << 30)),
    ];
    final before = rssMiB();
    events.forEach(store.apply);
    for (var i = 0; i < 10000; i++) {
      store.apply(progressEvent('m$i', i));
    }
    final grew = rssMiB() - before;
    // The events themselves are in memory too, so this overstates the cache.
    expect(grew, lessThan(150), reason: 'RSS grew by $grew MiB');
  });

  test('100 000 tasks (a very large history) still load and clear', () {
    final events = [for (var i = 0; i < 100000; i++) createdEvent(task('h$i'))];
    final watch = Stopwatch()..start();
    events.forEach(store.apply);
    expect(watch.elapsedMilliseconds, lessThan(12000));
    expect(store.tasks['h99999'], isNotNull);
    store.clear();
    expect(store.tasks['h0'], isNull);
  });
}
