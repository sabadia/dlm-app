import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late Redactor redactor;
  late AppLogger logger;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_diag');
    redactor = Redactor(homeDirectory: '/Users/alice');
    logger = AppLogger(
      directory: dir,
      redactor: redactor,
      maxFileBytes: 400,
      maxFiles: 3,
      memoryLines: 5,
      now: () => DateTime.utc(2026, 10, 30, 12),
    );
  });
  tearDown(() => dir.deleteSync(recursive: true));

  group('Redactor', () {
    test('hides authorization, cookies and bearer tokens', () {
      expect(
        redactor.redact(
          'GET /x\nAuthorization: Bearer abc.def-123\nCookie: sid=1; a=b\nok',
        ),
        'GET /x\nAuthorization: [redacted]\nCookie: [redacted]\nok',
      );
      expect(
        redactor.redact('sent Bearer tok_12345678 now'),
        'sent Bearer [redacted] now',
      );
      expect(
        redactor.redact('Set-Cookie: s=1; HttpOnly'),
        'Set-Cookie: [redacted]',
      );
    });

    test('hides credentials in URLs but keeps the host', () {
      expect(
        redactor.redact('fetch https://bob:hunter2@files.example.com/a.zip'),
        'fetch https://[redacted]@files.example.com/a.zip',
      );
      expect(redactor.redact('ftp://user@host/x'), 'ftp://[redacted]@host/x');
      expect(redactor.redact('https://example.com/a'), 'https://example.com/a');
    });

    test('hides secret-looking keys in text, query strings and JSON', () {
      expect(
        redactor.redact('url?token=abcdef&x=1'),
        'url?token=[redacted]&x=1',
      );
      expect(
        redactor.redact('{"password": "p@ss w0rd", "name": "n"}'),
        contains('"password": "[redacted]"'),
      );
      expect(
        redactor.redact('{"password": "p@ss w0rd", "name": "n"}'),
        contains('"name": "n"'),
      );
      expect(redactor.redact('api_key=xyz'), 'api_key=[redacted]');
      expect(
        redactor.redact('signature=AbC&sig=1'),
        'signature=[redacted]&sig=[redacted]',
      );
    });

    test('hides registered secrets wherever they appear', () {
      redactor.addSecret('s3cr3t-token-value');
      expect(redactor.redact('x s3cr3t-token-value y'), 'x [redacted] y');
      redactor.removeSecret('s3cr3t-token-value');
      expect(
        redactor.redact('x s3cr3t-token-value y'),
        'x s3cr3t-token-value y',
      );
      redactor.addSecret('abc'); // too short to be safe to match
      expect(redactor.redact('abc'), 'abc');
    });

    test('replaces the home directory', () {
      expect(
        redactor.redact('open /Users/alice/Downloads/f'),
        'open ~/Downloads/f',
      );
    });

    test('leaves ordinary text alone', () {
      const text = 'task t1 moved to queue main (3 of 10) at 12:00';
      expect(redactor.redact(text), text);
    });
  });

  group('AppLogger', () {
    test('writes redacted, timestamped lines to the file and memory', () {
      redactor.addSecret('tok-123456');
      logger
        ..info('connecting with tok-123456')
        ..warning('slow', error: 'timeout')
        ..debug('dropped'); // below the default level
      final text = logger.files().first.readAsStringSync();
      expect(
        text,
        contains('2026-10-30T12:00:00.000Z INFO    connecting with [redacted]'),
      );
      expect(text, contains('WARNING slow | timeout'));
      expect(text, isNot(contains('dropped')));
      expect(text, isNot(contains('tok-123456')));
      expect(logger.recent, hasLength(2));
    });

    test('keeps only the last lines in memory', () {
      for (var i = 0; i < 9; i++) {
        logger.info('line $i');
      }
      expect(logger.recent, hasLength(5));
      expect(logger.recent.first, contains('line 4'));
    });

    test('rotates by size and keeps a bounded number of files', () {
      for (var i = 0; i < 60; i++) {
        logger.info('a line of reasonable length to fill the file number $i');
      }
      final files = logger.files();
      expect(files.length, lessThanOrEqualTo(3));
      expect(files.length, greaterThan(1));
      expect(files.first.path, endsWith('dlm-app.log'));
      for (final f in files) {
        expect(f.lengthSync(), lessThan(400 + 200), reason: f.path);
      }
      expect(logger.files().first.readAsStringSync(), contains('number 59'));
    });

    test('a directory that cannot be written does not break logging', () {
      final broken = AppLogger(
        directory: Directory('${dir.path}/file.txt/sub'),
        redactor: redactor,
      );
      File('${dir.path}/file.txt').writeAsStringSync('not a directory');
      expect(() => broken.error('x'), returnsNormally);
      expect(broken.recent, hasLength(1));
    });
  });

  group('CrashReporter', () {
    test('writes a redacted crash file and a log line', () {
      redactor.addSecret('tok-123456');
      final crashes = CrashReporter(
        directory: dir,
        logger: logger,
        now: () => DateTime.utc(2026, 10, 30, 12, 30),
      )..record(StateError('bad tok-123456'), StackTrace.current, fatal: true);
      final files = crashes.crashFiles();
      expect(files, hasLength(1));
      final text = files.single.readAsStringSync();
      expect(text, startsWith('FATAL 2026-10-30T12-30-00.000Z'));
      expect(text, contains('bad [redacted]'));
      expect(text, isNot(contains('tok-123456')));
      expect(logger.recent.last, contains('fatal error'));
    });

    test('keeps only the newest crash files', () {
      var minute = 0;
      final crashes = CrashReporter(
        directory: dir,
        logger: logger,
        keep: 3,
        now: () => DateTime.utc(2026, 10, 30, 12, minute++),
      );
      for (var i = 0; i < 6; i++) {
        crashes.record(Exception('e$i'), StackTrace.current);
      }
      final files = crashes.crashFiles();
      expect(files, hasLength(3));
      expect(files.first.readAsStringSync(), contains('e5'));
    });
  });

  group('buildDiagnostics', () {
    test('has what support needs and no secrets', () {
      redactor.addSecret('tok-123456');
      logger.info('using tok-123456 from /Users/alice/x');
      final text = buildDiagnostics(
        redactor: redactor,
        appVersion: '0.1.0+1',
        operatingSystem: 'macos 26.0',
        locale: 'en_US',
        logger: logger,
        activeProfileId: 'nas',
        profiles: const [
          ConnectionProfile.local(),
          ConnectionProfile(
            id: 'nas',
            name: 'NAS',
            kind: ProfileKind.remote,
            url: 'https://admin:hunter2@nas.lan:17171/api?token=zzzzzz',
            tlsPin: 'sha256:aa',
          ),
        ],
        daemonInfo: {
          'version': '0.3.0',
          'paths': {'config': '/Users/alice/.config/dlm'},
        },
        now: DateTime.utc(2026, 10, 30, 13),
      );
      expect(text, contains('app: 0.1.0+1'));
      expect(text, contains('os: macos 26.0'));
      expect(
        text,
        contains('- NAS (active): remote, nas.lan:17171, certificate pinned'),
      );
      expect(text, contains('- This computer: local, managed daemon'));
      expect(text, contains('"version": "0.3.0"'));
      expect(text, contains('~/.config/dlm'));
      expect(text, isNot(contains('tok-123456')));
      expect(text, isNot(contains('hunter2')));
      expect(text, isNot(contains('zzzzzz')));
      expect(text, isNot(contains('alice')));
    });

    test('says when no daemon is connected', () {
      final text = buildDiagnostics(
        redactor: redactor,
        appVersion: '1',
        operatingSystem: 'linux',
        profiles: const [ConnectionProfile.local()],
        logger: logger,
      );
      expect(text, contains('not connected'));
    });
  });
}
