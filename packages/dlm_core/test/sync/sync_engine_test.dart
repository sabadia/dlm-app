import 'dart:async';
import 'dart:convert';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

import '../support/fakes.dart';

void main() {
  test('events patch the store, a reset empties it and reports', () async {
    // ignore: close_sinks
    final frames = StreamController<SseFrame>();
    addTearDown(frames.close);
    final hub = EventHub(
      open: (_, _) => frames.stream,
      flushInterval: const Duration(milliseconds: 1),
    );
    final store = TaskStore();
    var resets = 0;
    final engine = SyncEngine(
      hub: hub,
      store: store,
      onReset: () async => resets++,
    );
    final states = <HubConnectionState>[];
    engine.connection.listen(states.add);
    addTearDown(engine.dispose);

    store.tasks.put('a', task('a', status: 'running'));
    engine.start();
    frames
      ..add(const SseComment())
      ..add(
        SseData(
          SseMessage(
            id: 'b-1',
            event: 'task.status',
            data: jsonEncode({
              'id': 1,
              'type': 'task.status',
              'taskId': 'a',
              'time': '2026-10-30T10:00:00Z',
              'data': {'from': 'running', 'to': 'paused'},
            }),
          ),
        ),
      );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(store.tasks['a']!.statusKind, TaskStatus.paused);
    expect(states, contains(HubConnectionState.connected));

    frames.add(
      SseData(
        SseMessage(
          id: 'b-9',
          event: 'reset',
          data: jsonEncode({'reason': 'gap'}),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(store.tasks['a'], isNull, reason: 'stale state is dropped');
    expect(resets, 1);
  });
}
