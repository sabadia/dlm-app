import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

/// A daemon with versioned global settings, like the real one.
class SettingsDaemon {
  SettingsDaemon._(this.server);

  final HttpServer server;
  Map<String, Object?> global = {'maxConnections': 8};
  int version = 1;
  final patches = <Map<String, Object?>>[];

  static Future<SettingsDaemon> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final d = SettingsDaemon._(server);
    server.listen(d._handle);
    addTearDown(() => server.close(force: true));
    return d;
  }

  String get etag => '"v$version"';

  Future<void> _handle(HttpRequest r) async {
    final res = r.response..headers.contentType = ContentType.json;
    switch ((r.method, r.uri.path)) {
      case ('GET', '/v1/settings'):
        res.headers.set('ETag', etag);
        res.write(jsonEncode(global));
      case ('GET', '/v1/settings/defaults'):
        res.write(jsonEncode({'maxConnections': 16, 'tlsVerify': true}));
      case ('PATCH', '/v1/settings'):
        final ifMatch = r.headers.value('if-match');
        if (ifMatch != null && ifMatch != etag) {
          res
            ..statusCode = 412
            ..headers.contentType = ContentType.parse(
              'application/problem+json',
            )
            ..write(
              jsonEncode({
                'title': 'Precondition Failed',
                'status': 412,
                'code': 'settings.changed',
              }),
            );
        } else {
          final patch = jsonDecode(
            await utf8.decoder.bind(r).join(),
          ) as Map<String, Object?>;
          patches.add(patch);
          for (final e in patch.entries) {
            if (e.value == null) {
              global.remove(e.key);
            } else {
              global[e.key] = e.value;
            }
          }
          version++;
          res.write(jsonEncode(global));
        }
      case ('GET', '/v1/tasks/t1/settings/effective'):
        res.write(
          jsonEncode({
            'settings': {
              'maxConnections': 4,
              'retry': {'maxAttempts': 3},
            },
            'sources': {
              'maxConnections': 'task',
              'retry.maxAttempts': 'global',
            },
          }),
        );
      default:
        res.statusCode = 404;
    }
    await res.close();
  }
}

void main() {
  late SettingsDaemon daemon;
  late ProviderContainer container;

  setUp(() async {
    daemon = await SettingsDaemon.start();
    final api = DlmApi(
      DlmEndpoint(baseUrl: 'http://127.0.0.1:${daemon.server.port}'),
    );
    addTearDown(() => api.close(force: true));
    container = ProviderContainer.test(
      overrides: [apiProvider.overrideWithValue(api)],
    );
  });

  test('loads the global layer with its version and the defaults', () async {
    final g = await container.read(globalSettingsProvider.future);
    expect(g.settings.maxConnections, 8);
    expect(g.defaults.maxConnections, 16);
    expect(g.etag, '"v1"');
  });

  test('a patch is sent with the version it was based on', () async {
    await container.read(globalSettingsProvider.future);
    final c = container.read(globalSettingsProvider.notifier);
    await c.patch({'maxConnections': 12});
    expect(daemon.patches.single, {'maxConnections': 12});
    final after = container.read(globalSettingsProvider).requireValue;
    expect(after.settings.maxConnections, 12);
    expect(
      after.etag,
      '"v2"',
      reason: 'the next patch builds on the new version',
    );
    await c.patch({'maxConnections': null});
    expect(
      container
          .read(globalSettingsProvider)
          .requireValue
          .settings
          .maxConnections,
      isNull,
    );
  });

  test(
    'a patch based on stale settings is refused and the new state is loaded',
    () async {
      await container.read(globalSettingsProvider.future);
      // Somebody else changes the settings behind our back.
      daemon
        ..global = {'maxConnections': 2, 'userAgent': 'other'}
        ..version = 5;
      final c = container.read(globalSettingsProvider.notifier);
      await expectLater(
        c.patch({'maxConnections': 12}),
        throwsA(
          isA<ApiProblem>().having((p) => p.isPreconditionFailed, '412', true),
        ),
      );
      expect(daemon.patches, isEmpty, reason: 'nothing was overwritten');
      final now = container.read(globalSettingsProvider).requireValue;
      expect(
        now.settings.maxConnections,
        2,
        reason: 'the newest state is shown',
      );
      expect(now.etag, '"v5"');
      await c.patch({'maxConnections': 12}); // and a retry works
      expect(daemon.global['maxConnections'], 12);
    },
  );

  test('effective settings say where each value comes from', () async {
    final e = await container.read(taskEffectiveSettingsProvider('t1').future);
    expect(e.settings.maxConnections, 4);
    expect(e.levelOf('maxConnections'), SettingLevel.task);
    expect(e.levelOf('retry.maxAttempts'), SettingLevel.global);
    expect(e.levelOf('userAgent'), SettingLevel.defaults);
    expect(e.isOverridden('maxConnections'), isTrue);
    expect(e.isOverridden('userAgent'), isFalse);
    expect(SettingLevel.parse('default'), SettingLevel.defaults);
    expect(SettingLevel.parse('queue'), SettingLevel.queue);
    expect(SettingLevel.parse('???'), SettingLevel.defaults);
  });

  test('a settings.updated event reloads the settings', () async {
    final frames = StreamController<SseFrame>();
    addTearDown(frames.close);
    final api = container.read(apiProvider);
    final c2 = ProviderContainer.test(
      overrides: [
        sessionProvider.overrideWithValue(
          DlmSession(
            api: api,
            hub: EventHub(
              open: (_, _) => frames.stream,
              flushInterval: const Duration(milliseconds: 1),
            ),
          ),
        ),
      ],
    );
    expect(
      (await c2.read(globalSettingsProvider.future)).settings.maxConnections,
      8,
    );
    c2.read(syncEngineProvider).start();
    daemon
      ..global = {'maxConnections': 3}
      ..version = 2;
    final reloaded = Completer<int?>();
    c2.listen(globalSettingsProvider, (_, next) {
      final v = next.value?.settings.maxConnections;
      if (v == 3 && !reloaded.isCompleted) reloaded.complete(v);
    });
    frames.add(
      SseData(
        SseMessage(
          id: 'b-1',
          event: 'settings.updated',
          data: jsonEncode({
            'id': 1,
            'type': 'settings.updated',
            'time': '2026-10-30T10:00:00Z',
            'data': {'maxConnections': 3},
          }),
        ),
      ),
    );
    expect(await reloaded.future.timeout(const Duration(seconds: 5)), 3);
  });
}
