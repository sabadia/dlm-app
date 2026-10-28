import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

/// The generated client and the pinned spec must agree: every operation of
/// the spec has a generated method and nothing is stale.
void main() {
  final spec = jsonDecode(
    File('spec/openapi-3.0.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final paths = spec['paths']! as Map<String, Object?>;
  final generated = Directory('lib/src/generated')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_client.dart'))
      .map((f) => f.readAsStringSync())
      .join('\n');

  test('the spec is OpenAPI 3.0', () {
    expect(spec['openapi'], startsWith('3.0'));
  });

  test('every operation of the spec has a generated method', () {
    final missing = <String>[];
    for (final MapEntry(key: path, value: item) in paths.entries) {
      for (final method in (item! as Map<String, Object?>).keys) {
        if (!const {'get', 'put', 'post', 'delete', 'patch'}.contains(method)) {
          continue;
        }
        final annotation = "@${method.toUpperCase()}('$path'";
        if (!generated.contains(annotation)) missing.add('$method $path');
      }
    }
    expect(missing, isEmpty, reason: 'regenerate with tool/generate.sh');
  });

  test('the generated sources record the spec they came from', () {
    final recorded = File('lib/src/generated/.spec-sha256')
        .readAsStringSync()
        .trim();
    final actual = sha256
        .convert(File('spec/openapi-3.0.json').readAsBytesSync())
        .toString();
    expect(recorded, actual, reason: 'spec changed: run tool/generate.sh');
  });
}
