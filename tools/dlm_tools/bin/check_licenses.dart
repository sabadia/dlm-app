import 'dart:convert';
import 'dart:io';

import 'package:dlm_tools/licenses.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _licenseFiles = [
  'LICENSE',
  'LICENSE.md',
  'LICENSE.txt',
  'LICENCE',
  'COPYING',
  'license',
];

/// Usage: dart run dlm_tools:check_licenses
///
/// Fails when a hosted dependency (from `.dart_tool/package_config.json`,
/// so run `dart pub get` first) has a copyleft or unrecognised licence that is
/// not listed in tools/license_allowlist.yaml with a reason.
void main() {
  final cfg = File('.dart_tool/package_config.json');
  if (!cfg.existsSync()) {
    stderr.writeln(
      'run `dart pub get` first (no .dart_tool/package_config.json)',
    );
    exit(2);
  }
  final allowFile = File('tools/license_allowlist.yaml');
  final allow = <String>{
    if (allowFile.existsSync())
      for (final k
          in ((loadYaml(allowFile.readAsStringSync()) as YamlMap?)?['packages']
                      as YamlMap? ??
                  YamlMap())
              .keys)
        k as String,
  };
  final packages =
      (jsonDecode(cfg.readAsStringSync()) as Map<String, dynamic>)['packages']
          as List<dynamic>;
  final problems = <String>[];
  final counts = <LicenseKind, int>{};
  for (final raw in packages) {
    final pkg = raw as Map<String, dynamic>;
    final name = pkg['name'] as String;
    final uri = Uri.parse(pkg['rootUri'] as String);
    // Workspace members and the SDKs are ours; hosted packages live in the
    // pub cache.
    final dir = uri.isAbsolute
        ? Directory.fromUri(uri)
        : Directory(p.normalize(p.join('.dart_tool', uri.toFilePath())));
    if (!dir.path.contains('pub-cache') && !dir.path.contains('.pub-cache')) {
      continue;
    }
    final file = _licenseFiles
        .map((f) => File(p.join(dir.path, f)))
        .where((f) => f.existsSync())
        .firstOrNull;
    final kind = file == null
        ? LicenseKind.unknown
        : classifyLicense(file.readAsStringSync());
    counts.update(kind, (n) => n + 1, ifAbsent: () => 1);
    if (!kind.allowed && !allow.contains(name)) {
      problems.add(
        '$name: ${kind.name}'
        '${file == null ? ' (no licence file)' : ''}',
      );
    }
  }
  stdout.writeln(
    'licences: ${counts.entries.map((e) => '${e.key.name}=${e.value}').join(' ')}',
  );
  if (problems.isNotEmpty) {
    stderr
      ..writeln(
        'licences needing a decision (add to tools/license_allowlist.yaml with a reason, or drop the dependency):',
      )
      ..writeln(problems.map((e) => '  $e').join('\n'));
    exit(1);
  }
}
