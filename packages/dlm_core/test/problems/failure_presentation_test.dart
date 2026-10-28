import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

ApiProblem problem(
  int status,
  String code, {
  Map<String, String> params = const {},
  List<ProblemDetail> errors = const [],
  String detail = 'english detail',
}) => ApiProblem(
  status: status,
  code: code,
  detail: detail,
  params: params,
  errors: errors,
);

void main() {
  test('a cancelled request shows nothing', () {
    expect(presentFailure(const ApiCancelled()), isNull);
  });

  test('connection trouble is a retryable banner', () {
    final lost = presentFailure(const ApiConnectionFailure('unreachable'))!;
    expect(
      (lost.messageKey, lost.surface, lost.retryable),
      ('connection.lost', Surface.banner, true),
    );
    final slow = presentFailure(
      const ApiConnectionFailure('slow', timedOut: true),
    )!;
    expect(slow.messageKey, 'connection.timeout');
    final cert = presentFailure(
      const ApiConnectionFailure('the daemon certificate is not trusted'),
    )!;
    expect(cert.messageKey, 'connection.certificate');
    expect(
      cert.retryable,
      isFalse,
      reason: 'asking again cannot fix a changed certificate',
    );
  });

  test('known codes keep their key and parameters, shown as a toast', () {
    final p = presentFailure(
      problem(404, 'task.not_found', params: {'id': 't1'}),
    )!;
    expect(p.messageKey, 'task.not_found');
    expect(p.params, {'id': 't1'});
    expect(p.surface, Surface.toast);
    expect(p.fallback, 'english detail');
  });

  test('an unknown code falls back to its status, with the daemon text', () {
    final p = presentFailure(problem(409, 'future.thing', detail: 'new rule'))!;
    expect(p.messageKey, 'conflict');
    expect(p.fallback, 'new rule');
    expect(presentFailure(problem(418, 'teapot'))!.messageKey, 'unknown');
  });

  test('decisions are dialogs, server trouble is a banner', () {
    expect(
      presentFailure(problem(401, 'unauthorized'))!.surface,
      Surface.dialog,
    );
    expect(
      presentFailure(problem(412, 'settings.changed'))!.surface,
      Surface.dialog,
    );
    final down = presentFailure(problem(503, 'service.unavailable'))!;
    expect((down.surface, down.retryable), (Surface.banner, true));
    expect(
      presentFailure(problem(500, 'server_error'))!.surface,
      Surface.banner,
    );
  });

  test('validation errors become field errors by settings path', () {
    final p = presentFailure(
      problem(
        422,
        'settings.invalid',
        errors: const [
          ProblemDetail(
            message: 'must be >= 1',
            location: 'body.maxConnections',
          ),
          ProblemDetail(
            message: 'too high',
            location: 'body.settings.retry.maxAttempts',
          ),
          ProblemDetail(
            message: 'bad host',
            location: 'body.proxyRules[0].hosts',
          ),
          ProblemDetail(message: 'second', location: 'body.maxConnections'),
          ProblemDetail(message: 'no location'),
        ],
      ),
    )!;
    expect(p.surface, Surface.field);
    expect(p.fieldErrors, {
      'maxConnections': ['must be >= 1', 'second'],
      'retry.maxAttempts': ['too high'],
      'proxyRules[0].hosts': ['bad host'],
    });
    expect(p.messageKey, 'settings.invalid');
  });

  test('locations normalise', () {
    expect(normalizeLocation('body.settings.quota.bytes'), 'quota.bytes');
    expect(normalizeLocation('body.name'), 'name');
    expect(normalizeLocation('body'), '');
    expect(normalizeLocation('query.limit'), 'query.limit');
  });

  test('anything else is a neutral toast', () {
    expect(presentFailure(StateError('boom'))!.messageKey, 'unknown');
  });
}
