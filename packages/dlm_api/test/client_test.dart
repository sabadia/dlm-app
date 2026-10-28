import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dlm_api/dlm_api.dart';
import 'package:test/test.dart';

/// A tiny daemon: [handler] answers every request.
Future<(HttpServer, DlmApi)> serve(
  FutureOr<void> Function(HttpRequest) handler, {
  String? token = 'secret',
  Duration receiveTimeout = const Duration(seconds: 5),
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((r) async {
    await handler(r);
    await r.response.close();
  });
  addTearDown(() => server.close(force: true));
  final api = DlmApi(
    DlmEndpoint(
      baseUrl: 'http://127.0.0.1:${server.port}',
      token: token,
      receiveTimeout: receiveTimeout,
    ),
  );
  addTearDown(() => api.close(force: true));
  return (server, api);
}

void json(HttpRequest r, int status, Object body, {String? type}) {
  r.response
    ..statusCode = status
    ..headers.contentType = ContentType.parse(type ?? 'application/json')
    ..write(jsonEncode(body));
}

const healthBody = {
  'status': 'ok',
  'version': '0.3.0',
  'apiVersion': 1,
  'minClientApi': 1,
  'authenticated': true,
};

void main() {
  test('sends the bearer token and decodes the model', () async {
    String? auth;
    String? agent;
    final (_, api) = await serve((r) {
      auth = r.headers.value('authorization');
      agent = r.headers.value('user-agent');
      json(r, 200, healthBody);
    });
    final health = await guard(() => api.rest.system.getHealth());
    expect(auth, 'Bearer secret');
    expect(agent, 'dlm-app');
    expect(health.version, '0.3.0');
    expect(health.apiVersion, 1);
  });

  test('sends no Authorization header without a token', () async {
    String? auth = 'unset';
    final (_, api) = await serve((r) {
      auth = r.headers.value('authorization');
      json(r, 200, healthBody);
    }, token: null);
    await guard(() => api.rest.system.getHealth());
    expect(auth, isNull);
  });

  test(
    'a problem response becomes an ApiProblem with code and params',
    () async {
      final (_, api) = await serve((r) {
        json(r, 404, {
          'type': 'urn:dlm:problem:task.not_found',
          'title': 'Not Found',
          'status': 404,
          'detail': 'domain: task "x" not found',
          'code': 'task.not_found',
          'params': {'entity': 'task', 'id': 'x'},
        }, type: 'application/problem+json');
      });
      await expectLater(
        guard(() => api.rest.tasks.getTask(id: 'x')),
        throwsA(
          isA<ApiProblem>()
              .having((p) => p.status, 'status', 404)
              .having((p) => p.code, 'code', 'task.not_found')
              .having((p) => p.params['id'], 'params.id', 'x')
              .having((p) => p.detail, 'detail', contains('not found')),
        ),
      );
    },
  );

  test('validation errors keep their locations', () async {
    final (_, api) = await serve((r) {
      json(r, 422, {
        'title': 'Unprocessable Content',
        'status': 422,
        'code': 'settings.invalid',
        'errors': [
          {'message': 'must be >= 1', 'location': 'body.maxConnections'},
          {'message': 'broken'},
        ],
      }, type: 'application/problem+json');
    });
    Object? failure;
    try {
      await guard(() => api.rest.tasks.getTask(id: 'x'));
    } on Object catch (e) {
      failure = e;
    }
    final problem = failure! as ApiProblem;
    expect(problem.code, 'settings.invalid');
    expect(problem.errors.map((e) => e.location), [
      'body.maxConnections',
      null,
    ]);
    expect(problem.errors.first.message, 'must be >= 1');
  });

  test(
    'a body that is not a problem still yields a code from the status',
    () async {
      final (_, api) = await serve((r) {
        r.response
          ..statusCode = 502
          ..write('<html>bad gateway</html>');
      });
      await expectLater(
        guard(() => api.rest.system.getHealth()),
        throwsA(
          isA<ApiProblem>()
              .having((p) => p.status, 'status', 502)
              .having((p) => p.code, 'code', 'server_error'),
        ),
      );
    },
  );

  test('a refused update reports the precondition failure', () {
    final p = ApiProblem.fromJson(412, {'code': 'settings.changed'});
    expect(p.isPreconditionFailed, isTrue);
    expect(ApiProblem.fromJson(412, null).code, 'settings.changed');
  });

  test('an unreachable daemon is a connection failure', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close(force: true);
    final api = DlmApi(DlmEndpoint(baseUrl: 'http://127.0.0.1:$port'));
    addTearDown(() => api.close(force: true));
    await expectLater(
      guard(() => api.rest.system.getHealth()),
      throwsA(
        isA<ApiConnectionFailure>().having(
          (f) => f.timedOut,
          'timedOut',
          false,
        ),
      ),
    );
  });

  test('a slow daemon times out', () async {
    final (_, api) = await serve((r) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      json(r, 200, healthBody);
    }, receiveTimeout: const Duration(milliseconds: 150));
    await expectLater(
      guard(() => api.rest.system.getHealth()),
      throwsA(isA<ApiConnectionFailure>().having((f) => f.timedOut, 't', true)),
    );
  });

  test('cancellable calls stop when their token is cancelled', () async {
    final hold = Completer<void>();
    final (_, api) = await serve((r) async {
      await hold.future.timeout(const Duration(seconds: 3), onTimeout: () {});
      json(r, 200, healthBody);
    });
    addTearDown(() {
      if (!hold.isCompleted) hold.complete();
    });
    final token = CancelToken();
    final call = api.cancellable(
      token,
      () => guard(() => api.rest.system.getHealth()),
    );
    final outcome = expectLater(call, throwsA(isA<ApiCancelled>()));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    token.cancel();
    await outcome;
  });

  test('calls outside cancellable are not affected by other tokens', () async {
    final (_, api) = await serve((r) => json(r, 200, healthBody));
    final token = CancelToken()..cancel();
    // Started in the root zone: the cancelled token must not apply.
    expect(
      (await guard(() => api.rest.system.getHealth())).status,
      HealthOutputBodyStatus.ok,
    );
    expect(token.isCancelled, isTrue);
  });

  test('remembers the ETag of GET responses by path', () async {
    final (_, api) = await serve((r) {
      r.response.headers.set('ETag', '"abc"');
      json(r, 200, healthBody);
    });
    expect(api.etagFor('/v1/health'), isNull);
    await guard(() => api.rest.system.getHealth());
    expect(api.etagFor('/v1/health'), '"abc"');
  });
}
