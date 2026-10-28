import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'the hub streams over real HTTP and resumes with Last-Event-ID',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requests = <({String? last, String? query, String? auth})>[];
      var served = 0;
      server.listen((r) async {
        requests.add((
          last: r.headers.value('last-event-id'),
          query: r.uri.query,
          auth: r.headers.value('authorization'),
        ));
        served++;
        r.response
          ..bufferOutput = false
          ..headers.contentType = ContentType.parse('text/event-stream');
        r.response.write(': hello\n\n');
        if (served == 1) {
          final event = jsonEncode({
            'id': 1,
            'type': 'task.status',
            'taskId': 't',
            'time': '2026-10-29T12:00:00Z',
            'data': {'from': 'queued', 'to': 'running'},
          });
          r.response.write('id: b-1\nevent: task.status\ndata: $event\n\n');
          await r.response.close(); // the connection drops after one event
        } else {
          r.response.write('id: b-2\nevent: reset\ndata: {"reason":"gap"}\n\n');
          await r.response.flush();
        }
      });

      final api = DlmApi(
        DlmEndpoint(baseUrl: 'http://127.0.0.1:${server.port}', token: 'tok'),
      );
      addTearDown(() => api.close(force: true));
      final hub = EventHub(
        open: dioSseOpener(api.dio),
        filter: const EventFilter(types: {'task.status'}),
        backoff: const Backoff(initial: Duration(milliseconds: 20)),
      );
      addTearDown(hub.dispose);
      final events = <HubEvent>[];
      final gotReset = Completer<void>();
      hub.events.listen((e) {
        events.add(e);
        if (e is HubReset && !gotReset.isCompleted) gotReset.complete();
      });
      hub.start();
      await gotReset.future.timeout(const Duration(seconds: 10));

      expect(
        events.whereType<HubStreamEvent>().single.event,
        isA<StreamEventTaskStatusEvent>(),
      );
      expect(requests, hasLength(2));
      expect(requests[0].last, isNull);
      expect(requests[1].last, 'b-1');
      expect(requests[1].query, 'types=task.status');
      expect(requests[1].auth, 'Bearer tok');
      expect(hub.state, HubConnectionState.connected);
    },
  );
}
