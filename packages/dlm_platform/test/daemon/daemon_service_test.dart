import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json =
      '{"kind":"launchd","installed":true,"active":false,"path":"/p.plist"}';

  test('asks for json with the daemon home and decodes the status', () async {
    late List<String> seen;
    final service = DaemonService(
      executable: '/bin/dlm',
      home: '/h',
      run: (exe, args) async {
        seen = args;
        return ProcessResult(1, 0, json, '');
      },
    );
    final st = await service.install();
    expect(seen, ['--home', '/h', 'service', 'install', '--output', 'json']);
    expect(st.kind, 'launchd');
    expect(st.installed, isTrue);
    expect(st.active, isFalse);
    expect(st.path, '/p.plist');
  });

  test('a failing command raises with the daemon message', () async {
    final service = DaemonService(
      executable: '/bin/dlm',
      run: (_, _) async => ProcessResult(1, 1, '', 'no systemd'),
    );
    await expectLater(
      service.status(),
      throwsA(
        isA<LoginItemException>().having((e) => e.message, 'm', 'no systemd'),
      ),
    );
  });

  test('output that is not a status raises', () async {
    final service = DaemonService(
      executable: '/bin/dlm',
      run: (_, _) async => ProcessResult(1, 0, 'hello', ''),
    );
    await expectLater(service.status(), throwsA(isA<LoginItemException>()));
  });

  test('a missing binary raises', () async {
    final service = DaemonService(
      executable: '/bin/dlm',
      run: (_, _) async => throw const ProcessException('/bin/dlm', []),
    );
    await expectLater(service.status(), throwsA(isA<LoginItemException>()));
  });
}
