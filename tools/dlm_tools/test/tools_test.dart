import 'dart:convert';
import 'dart:io';

import 'package:dlm_tools/licenses.dart';
import 'package:dlm_tools/sbom.dart';
import 'package:dlm_tools/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('classifyLicense', () {
    final cases = {
      LicenseKind.apache2: 'Apache License\n Version 2.0, January 2004',
      LicenseKind.mit: 'MIT License\n\nPermission is hereby granted,\nfree of charge, to any person',
      LicenseKind.bsd:
          'Redistribution and use in source and binary forms, with or without',
      LicenseKind.mpl2: 'Mozilla Public License Version 2.0',
      LicenseKind.isc:
          'Permission to use, copy, modify, and/or distribute this software',
      LicenseKind.publicDomain: 'This is free and unencumbered software released into the public domain.',
      LicenseKind.copyleft: 'GNU GENERAL PUBLIC LICENSE Version 3',
      LicenseKind.unknown: 'All rights reserved.',
    };
    for (final c in cases.entries) {
      test(c.key.name, () => expect(classifyLicense(c.value), c.key));
    }

    test('LGPL and AGPL are copyleft too', () {
      expect(
        classifyLicense('GNU Lesser General Public License v3'),
        LicenseKind.copyleft,
      );
      expect(
        classifyLicense('GNU Affero General Public License'),
        LicenseKind.copyleft,
      );
    });

    test('only compatible licences are allowed', () {
      expect(LicenseKind.mit.allowed, isTrue);
      expect(LicenseKind.mpl2.allowed, isTrue);
      expect(LicenseKind.copyleft.allowed, isFalse);
      expect(LicenseKind.unknown.allowed, isFalse);
    });
  });

  test('sbomFromLock lists hosted and git packages only, sorted', () {
    const lock = '''
packages:
  zeta:
    dependency: transitive
    description: {name: zeta, sha256: "aa11", url: "https://pub.dev"}
    source: hosted
    version: "1.2.3"
  alpha:
    dependency: "direct dev"
    description: {name: alpha, sha256: "bb22", url: "https://pub.dev"}
    source: hosted
    version: "0.1.0"
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
  mine:
    dependency: "direct main"
    description: {path: "../mine", relative: true}
    source: path
    version: "1.0.0"
sdks:
  dart: ">=3.13.0 <4.0.0"
''';
    final bom = sbomFromLock(
      lock,
      appName: 'dlm-app',
      appVersion: '1.0.0',
      now: DateTime.utc(2026, 10, 28),
    );
    final json = jsonDecode(jsonEncode(bom)) as Map<String, dynamic>;
    expect(json['bomFormat'], 'CycloneDX');
    final comps = json['components'] as List<dynamic>;
    expect(comps.map((c) => (c as Map)['name']), ['alpha', 'zeta']);
    final alpha = comps.first as Map<String, dynamic>;
    expect(alpha['purl'], 'pkg:pub/alpha@0.1.0');
    expect(alpha['scope'], 'excluded');
    expect(alpha['hashes'], [
      {'alg': 'SHA-256', 'content': 'bb22'},
    ]);
    expect(((json['metadata'] as Map)['component'] as Map)['version'], '1.0.0');
  });

  group('workspaceMembers', () {
    late Directory root;
    setUp(() => root = Directory.systemTemp.createTempSync('dlm_ws'));
    tearDown(() => root.deleteSync(recursive: true));

    void member(String dir, String pubspec, {bool tests = false}) {
      final d = Directory(p.join(root.path, dir))..createSync(recursive: true);
      File(p.join(d.path, 'pubspec.yaml')).writeAsStringSync(pubspec);
      if (tests) Directory(p.join(d.path, 'test')).createSync();
    }

    test('finds members, tests and the Flutter SDK dependency', () {
      File(p.join(root.path, 'pubspec.yaml')).writeAsStringSync(
        'name: ws\nworkspace:\n  - packages/a\n  - packages/b\n  - packages/missing\n',
      );
      member(
        'packages/a',
        'name: a\ndependencies:\n  flutter:\n    sdk: flutter\n',
        tests: true,
      );
      member('packages/b', 'name: b\ndependencies:\n  path: ^1.0.0\n');
      final ms = workspaceMembers(root.path);
      expect(ms.map((m) => m.name), ['a', 'b']);
      expect(ms[0].usesFlutter, isTrue);
      expect(ms[0].hasTests, isTrue);
      expect(ms[1].usesFlutter, isFalse);
      expect(ms[1].hasTests, isFalse);
      expect(testCommand(ms[0], ['--exclude-tags', 'golden']), [
        'flutter',
        'test',
        '--exclude-tags',
        'golden',
      ]);
      expect(testCommand(ms[1], []), ['dart', 'test']);
    });
  });
}
