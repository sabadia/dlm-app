import 'dart:convert';

import 'package:yaml/yaml.dart';

/// Builds a CycloneDX 1.5 software bill of materials from the text of a
/// `pubspec.lock`. Only hosted and git packages are listed (SDK and path
/// packages are part of the project itself).
Map<String, Object?> sbomFromLock(
  String lockText, {
  required String appName,
  required String appVersion,
  DateTime? now,
}) {
  final lock = loadYaml(lockText) as YamlMap;
  final components = <Map<String, Object?>>[];
  final packages = (lock['packages'] as YamlMap?) ?? YamlMap();
  for (final e in packages.entries) {
    final v = e.value as YamlMap;
    final source = v['source'];
    if (source != 'hosted' && source != 'git') continue;
    final name = e.key as String;
    final version = v['version'] as String;
    final desc = v['description'];
    final hash = desc is YamlMap ? desc['sha256'] as String? : null;
    components.add({
      'type': 'library',
      'name': name,
      'version': version,
      'purl': 'pkg:pub/$name@$version',
      'scope': v['dependency'] == 'direct dev' ? 'excluded' : 'required',
      if (hash != null)
        'hashes': [
          {'alg': 'SHA-256', 'content': hash},
        ],
    });
  }
  components.sort(
    (a, b) => (a['name']! as String).compareTo(b['name']! as String),
  );
  return {
    'bomFormat': 'CycloneDX',
    'specVersion': '1.5',
    'version': 1,
    'metadata': {
      'timestamp': (now ?? DateTime.now().toUtc()).toIso8601String(),
      'component': {
        'type': 'application',
        'name': appName,
        'version': appVersion,
      },
    },
    'components': components,
  };
}

/// [sbomFromLock] as pretty JSON.
String sbomJson(
  String lockText, {
  required String appName,
  required String appVersion,
}) => const JsonEncoder.withIndent('  ')
    .convert(sbomFromLock(lockText, appName: appName, appVersion: appVersion));
