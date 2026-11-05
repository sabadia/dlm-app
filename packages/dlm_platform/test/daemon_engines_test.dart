import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('dlm-engines'));
  tearDown(() => root.deleteSync(recursive: true));

  void fakeEngine(String version) {
    final dir = Directory('${root.path}/engines/$version')
      ..createSync(recursive: true);
    File('${dir.path}/dlm').writeAsStringSync('#!/bin/sh\n');
  }

  DaemonEngines engines({EngineFetch? fetch}) => DaemonEngines(
    '${root.path}/engines',
    fetch: fetch,
    operatingSystem: 'linux',
    architecture: 'amd64',
  );

  test('compareVersions orders by number, not text', () {
    expect(compareVersions('0.10.0', '0.9.9'), 1);
    expect(compareVersions('v0.7.3', '0.7.3'), 0);
    expect(compareVersions('0.7.3', '0.7.4'), -1);
  });

  test('the installed build wins only when it is newer than the bundled', () {
    fakeEngine('0.7.4');
    fakeEngine('0.7.2');
    expect(engines().installed().map((e) => e.version), ['0.7.4', '0.7.2']);
    expect(engines().preferred(bundled: '0.7.3')?.version, '0.7.4');
    expect(engines().preferred(bundled: '0.7.4'), isNull);
    expect(engines().preferred(bundled: '0.8.0'), isNull);
    expect(engines().preferred(bundled: '')?.version, '0.7.4');
  });

  test('nothing installed means the bundled build runs', () {
    expect(engines().preferred(bundled: '0.7.3'), isNull);
  });

  group('install', () {
    late List<int> archive;
    late String sums;

    setUp(() {
      final src = Directory('${root.path}/src')..createSync();
      File('${src.path}/dlm').writeAsStringSync('#!/bin/sh\necho dlm\n');
      final tar = Process.runSync('tar', [
        '-czf',
        '${root.path}/a.tar.gz',
        '-C',
        src.path,
        'dlm',
      ]);
      expect(tar.exitCode, 0);
      archive = File('${root.path}/a.tar.gz').readAsBytesSync();
      sums =
          '${sha256.convert(archive)}  dlm_0.7.4_linux_amd64.tar.gz\n'
          '${'0' * 64}  dlm_0.7.4_windows_amd64.zip\n';
    });

    EngineFetch serve({List<int>? body, String? checksums}) => (url) async {
      if (url.path.endsWith('checksums.txt')) {
        return utf8.encode(checksums ?? sums);
      }
      if (url.path.endsWith('.tar.gz')) return body ?? archive;
      throw HttpException('404', uri: url);
    };

    const release = EngineRelease(tag: 'v0.7.4', page: '');

    test('unpacks a checked archive into a version directory', () async {
      final built = await engines(fetch: serve()).install(release);
      expect(built.version, '0.7.4');
      expect(File(built.path).existsSync(), isTrue);
      expect(built.path, endsWith('/engines/0.7.4/dlm'));
      expect(engines().preferred(bundled: '0.7.3')?.path, built.path);
      expect(
        Directory('${root.path}/engines')
            .listSync()
            .map((e) => e.uri.pathSegments.where((s) => s.isNotEmpty).last),
        ['0.7.4'],
        reason: 'no work directory is left behind',
      );
    });

    test('refuses an archive that does not match its checksum', () async {
      await expectLater(
        engines(fetch: serve(body: [...archive, 0])).install(release),
        throwsA(isA<EngineUpdateException>()),
      );
      expect(engines().installed(), isEmpty);
    });

    test('refuses a release with no checksum for this machine', () async {
      await expectLater(
        engines(fetch: serve(checksums: '')).install(release),
        throwsA(isA<EngineUpdateException>()),
      );
    });

    test('keeps the newest two installed versions', () async {
      fakeEngine('0.7.1');
      fakeEngine('0.7.2');
      await engines(fetch: serve()).install(release);
      expect(engines().installed().map((e) => e.version), ['0.7.4', '0.7.2']);
    });
  });

  test('latest reads the tag of the newest release', () async {
    final e = engines(
      fetch: (url) async => utf8.encode(
        jsonEncode({'tag_name': 'v0.7.9', 'html_url': 'https://x/y'}),
      ),
    );
    final r = await e.latest();
    expect((r.tag, r.version, r.page), ('v0.7.9', '0.7.9', 'https://x/y'));
  });
}
