import 'package:dlm_tools/contract.dart';
import 'package:test/test.dart';

Map<String, Object?> doc(Map<String, Object?> paths) => {'paths': paths};

Map<String, Object?> op(
  List<String> codes, {
  List<String> required = const [],
}) => {
  'responses': {for (final c in codes) c: <String, Object?>{}},
  if (required.isNotEmpty)
    'requestBody': {
      'content': {
        'application/json': {
          'schema': {'required': required},
        },
      },
    },
};

void main() {
  final pinned = doc({
    '/v1/tasks': {
      'get': op(['200', '401']),
      'post': op(['201', '422'], required: ['url']),
    },
    '/v1/queues': {
      'get': op(['200']),
    },
  });

  test('the same document is compatible', () {
    final r = compareContracts(pinned, pinned);
    expect(r.breaking, isFalse);
    expect(r.added, isEmpty);
  });

  test('a new operation is reported but is not breaking', () {
    final r = compareContracts(
      pinned,
      doc({
        '/v1/tasks': {
          'get': op(['200', '401']),
          'post': op(['201', '422'], required: ['url']),
        },
        '/v1/queues': {
          'get': op(['200']),
        },
        '/v1/new': {
          'get': op(['200']),
        },
      }),
    );
    expect(r.breaking, isFalse);
    expect(r.added, ['GET /v1/new']);
  });

  test('a removed operation is breaking', () {
    final r = compareContracts(
      pinned,
      doc({
        '/v1/tasks': {
          'get': op(['200', '401']),
          'post': op(['201', '422'], required: ['url']),
        },
      }),
    );
    expect(r.breaking, isTrue);
    expect(r.removed, ['GET /v1/queues']);
  });

  test('a lost response code and a new required field are breaking', () {
    final r = compareContracts(
      pinned,
      doc({
        '/v1/tasks': {
          'get': op(['200']),
          'post': op(['201', '422'], required: ['url', 'queueId']),
        },
        '/v1/queues': {
          'get': op(['200']),
        },
      }),
    );
    expect(r.breaking, isTrue);
    expect(r.changed.length, 2);
    expect(r.changed.join(), contains('401'));
    expect(r.changed.join(), contains('queueId'));
  });
}
