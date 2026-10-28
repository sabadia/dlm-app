import 'dart:async';
import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

/// A scripted daemon: each call of the opener gets the next [Connection].
class Connection {
  final controller = StreamController<SseFrame>();
  void send(String event, Map<String, Object?> json, {String? id}) => controller
      .add(SseData(SseMessage(id: id, event: event, data: jsonEncode(json))));
  void keepAlive() => controller.add(const SseComment());
  void drop() => controller.close();
  void fail(Object e) => controller.addError(e);
}

class Harness {
  Harness({
    Duration heartbeat = const Duration(seconds: 45),
    EventFilter filter = const EventFilter(),
  }) {
    hub = EventHub(
      filter: filter,
      heartbeatTimeout: heartbeat,
      random: () => 0.5, // no jitter
      onMalformed: (e, _) => malformed.add(e),
      open: (f, last) {
        filters.add(f);
        resumedWith.add(last);
        final c = Connection();
        connections.add(c);
        return c.controller.stream;
      },
    );
    hub.events.listen(seen.add);
  }

  final connections = <Connection>[];
  final resumedWith = <String?>[];
  final filters = <EventFilter>[];
  final seen = <HubEvent>[];
  final malformed = <Object>[];
  late final EventHub hub;

  Connection get current => connections.last;
  List<String> get states => [
    for (final e in seen)
      if (e is HubConnection) e.state.name,
  ];
  List<String> get types => [
    for (final e in seen)
      if (e is HubStreamEvent) e.event.runtimeType.toString(),
  ];
}

Map<String, Object?> taskEvent(String type, String id, {Object? data}) => {
  'id': 1,
  'type': type,
  'taskId': id,
  'time': '2026-10-29T12:00:00Z',
  if (data != null) 'data': data,
};

Map<String, Object?> statusEvent(String id) =>
    taskEvent('task.status', id, data: {'from': 'queued', 'to': 'running'});

const progress = {
  'downloaded': 5,
  'size': 10,
  'speed': 1,
  'connections': 1,
  'eta': 5,
};

void main() {
  test('connects, delivers events and remembers the last id', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.keepAlive();
      h.current.send('task.status', statusEvent('a'), id: 'b1-4');
      async.elapse(const Duration(milliseconds: 50));
      expect(h.states, ['connecting', 'connected']);
      expect(h.types, ['StreamEventTaskStatusEvent']);
      expect(h.hub.lastEventId, 'b1-4');
      expect(h.resumedWith, [null]);
    });
  });

  test('reconnects with backoff and resumes after the last id', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.send('task.status', statusEvent('a'), id: 'b1-9');
      h.current.drop();
      async.elapse(const Duration(milliseconds: 499));
      expect(
        h.connections,
        hasLength(1),
        reason: 'waits the first backoff (500 ms)',
      );
      async.elapse(const Duration(milliseconds: 2));
      expect(h.connections, hasLength(2));
      expect(h.resumedWith, [null, 'b1-9']);
      // The second failure waits twice as long.
      h.current.drop();
      async.elapse(const Duration(milliseconds: 999));
      expect(h.connections, hasLength(2));
      async.elapse(const Duration(milliseconds: 2));
      expect(h.connections, hasLength(3));
      expect(h.states.where((s) => s == 'reconnecting'), isNotEmpty);
    });
  });

  test('a successful frame resets the backoff', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.drop();
      async.elapse(const Duration(milliseconds: 600));
      h.current.keepAlive(); // connected again: failures reset
      async.flushMicrotasks();
      h.current.drop();
      async.elapse(const Duration(milliseconds: 501));
      expect(
        h.connections,
        hasLength(3),
        reason: 'the delay is 500 ms again, not 1 s',
      );
    });
  });

  test('errors of the connection are reported with their failure', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.fail(const ApiProblem(status: 401, code: 'unauthorized'));
      async.flushMicrotasks();
      final failure = h.seen.whereType<HubConnection>().last.error;
      expect(failure, isA<ApiProblem>());
      expect(h.hub.state, HubConnectionState.reconnecting);
    });
  });

  test('silence beyond the heartbeat timeout reconnects', () {
    fakeAsync((async) {
      final h = Harness(heartbeat: const Duration(seconds: 30))..hub.start();
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 20));
      h.current.keepAlive(); // proof of life restarts the timer
      async..elapse(const Duration(seconds: 20));
      expect(h.connections, hasLength(1));
      async
        ..elapse(const Duration(seconds: 11)) // 31 s of silence
        ..elapse(const Duration(seconds: 1));
      expect(h.connections, hasLength(2));
      final err = h.seen
          .whereType<HubConnection>()
          .map((e) => e.error)
          .whereType<ApiConnectionFailure>();
      expect(err.single.timedOut, isTrue);
    });
  });

  test('a reset event is passed on and does not stop the stream', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.send('reset', {'reason': 'gap'}, id: 'b2-1');
      h.current.send('task.status', statusEvent('a'), id: 'b2-2');
      async.elapse(const Duration(milliseconds: 50));
      final reset = h.seen.whereType<HubReset>().single;
      expect(reset.reason, ResetDataReason.gap);
      expect(h.types, ['StreamEventTaskStatusEvent']);
      expect(h.hub.lastEventId, 'b2-2');
    });
  });

  test('progress is coalesced per task, other events keep their order', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.send(
        'task.progress',
        taskEvent('task.progress', 'a', data: {...progress, 'downloaded': 1}),
      );
      h.current.send(
        'task.progress',
        taskEvent('task.progress', 'b', data: progress),
      );
      h.current.send('task.status', statusEvent('c'));
      h.current.send(
        'task.progress',
        taskEvent('task.progress', 'a', data: {...progress, 'downloaded': 9}),
      );
      async.elapse(const Duration(milliseconds: 50));
      final events = h.seen
          .whereType<HubStreamEvent>()
          .map((e) => e.event)
          .toList();
      expect(events, hasLength(3), reason: 'two progress of task a became one');
      final first = events.first as StreamEventTaskProgressEvent;
      expect(first.taskId, 'a');
      expect(first.data.downloaded, 9, reason: 'the newest value wins');
      expect(events[2], isA<StreamEventTaskStatusEvent>());
    });
  });

  test('unknown or malformed events are skipped, not fatal', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      h.current.send('task.teleported', {'type': 'task.teleported', 'id': 1});
      h.current.controller.add(
        const SseData(SseMessage(event: 'x', data: 'not json')),
      );
      h.current.send('task.status', statusEvent('a'));
      async.elapse(const Duration(milliseconds: 50));
      expect(h.malformed, hasLength(2));
      expect(h.types, ['StreamEventTaskStatusEvent']);
      expect(h.hub.state, HubConnectionState.connected);
    });
  });

  test('stop disconnects for good; start works again', () {
    fakeAsync((async) {
      final h = Harness()..hub.start();
      async.flushMicrotasks();
      unawaited(h.hub.stop());
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));
      expect(h.connections, hasLength(1));
      expect(h.hub.state, HubConnectionState.closed);
      h.hub.start();
      async.flushMicrotasks();
      expect(h.connections, hasLength(2));
    });
  });

  test('the filter is passed to every connection', () {
    fakeAsync((async) {
      const f = EventFilter(
        types: {'task.progress', 'task.status'},
        taskId: 't1',
      );
      final h = Harness(filter: f)..hub.start();
      async.flushMicrotasks();
      h.current.drop();
      async.elapse(const Duration(seconds: 1));
      expect(h.filters, [f, f]);
      expect(f.query, {'types': 'task.progress,task.status', 'taskId': 't1'});
    });
  });

  test('backoff doubles, is capped and spreads with the random value', () {
    const b = Backoff();
    expect(b.delay(1, 0.5), const Duration(milliseconds: 500));
    expect(b.delay(3, 0.5), const Duration(seconds: 2));
    expect(b.delay(20, 0.5), const Duration(seconds: 30));
    expect(b.delay(1, 0), const Duration(milliseconds: 400));
    expect(b.delay(1, 1), const Duration(milliseconds: 600));
  });
}
