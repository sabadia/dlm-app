import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// One broken rule, ready to print.
class Violation {
  /// Creates a violation at [where] described by [message].
  const Violation(this.where, this.message);

  /// A file or pubspec path relative to the repository root.
  final String where;

  /// What is wrong.
  final String message;

  @override
  String toString() => '$where: $message';
}

/// The rules of `tools/import_rules.yaml`.
class ImportRules {
  /// Creates rules from the allowed dependencies and the skin registry files.
  ImportRules({required this.allowed, required this.skinRegistry});

  /// Parses the rules file.
  factory ImportRules.parse(String yamlText) {
    final doc = loadYaml(yamlText) as YamlMap;
    final packages = <String, Set<String>>{};
    for (final e in (doc['packages'] as YamlMap).entries) {
      final list = (e.value as YamlList?) ?? YamlList();
      packages[e.key as String] = {for (final d in list) d as String};
    }
    final registry = <String>{
      for (final f in (doc['skin_registry'] as YamlList?) ?? YamlList())
        p.posix.normalize(f as String),
    };
    return ImportRules(allowed: packages, skinRegistry: registry);
  }

  /// package -> the dlm_* packages it may use.
  final Map<String, Set<String>> allowed;

  /// Files (posix, relative to the root) that may import a skin.
  final Set<String> skinRegistry;
}

final _importRe = RegExp(
  r'''^\s*(?:import|export)\s+['"]package:(dlm_[a-z0-9_]+)/''',
  multiLine: true,
);

bool _isSkin(String package) => package.startsWith('dlm_skin_');

/// Checks every package under [root] (`apps/*` and `packages/*`) against
/// [rules] and returns the violations, sorted.
List<Violation> checkWorkspace(String root, ImportRules rules) {
  final violations = <Violation>[];
  for (final group in ['apps', 'packages']) {
    final dir = Directory(p.join(root, group));
    if (!dir.existsSync()) continue;
    for (final entry in dir.listSync().whereType<Directory>()) {
      final pubspec = File(p.join(entry.path, 'pubspec.yaml'));
      if (!pubspec.existsSync()) continue;
      violations.addAll(_checkPackage(root, entry.path, pubspec, rules));
    }
  }
  violations.sort((a, b) => a.toString().compareTo(b.toString()));
  return violations;
}

List<Violation> _checkPackage(
  String root,
  String dir,
  File pubspec,
  ImportRules rules,
) {
  final out = <Violation>[];
  final doc = loadYaml(pubspec.readAsStringSync()) as YamlMap;
  final name = doc['name'] as String;
  final rel = p.posix.joinAll(p.split(p.relative(pubspec.path, from: root)));
  final allowed = rules.allowed[name];
  if (allowed == null) {
    return [
      Violation(rel, 'package $name is not listed in tools/import_rules.yaml'),
    ];
  }

  void checkUse(String dep, String where, String how) {
    if (dep == name || allowed.contains(dep)) return;
    if (!rules.allowed.containsKey(dep)) {
      out.add(
        Violation(where, '$how $dep, which is not listed in import_rules.yaml'),
      );
    } else {
      out.add(
        Violation(
          where,
          '$name must not $how $dep (allowed: '
          '${allowed.isEmpty ? 'no dlm package' : (allowed.toList()..sort()).join(', ')})',
        ),
      );
    }
  }

  for (final section in [
    'dependencies',
    'dev_dependencies',
    'dependency_overrides',
  ]) {
    final deps = doc[section];
    if (deps is! YamlMap) continue;
    for (final dep in deps.keys.cast<String>().where(
      (d) => d.startsWith('dlm_'),
    )) {
      checkUse(dep, rel, 'depend on');
    }
  }

  for (final file in Directory(dir).listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.dart')) continue;
    final relFile = p.posix.joinAll(p.split(p.relative(file.path, from: root)));
    if (relFile.contains('/.dart_tool/') || relFile.contains('/build/')) {
      continue;
    }
    final text = file.readAsStringSync();
    for (final m in _importRe.allMatches(text)) {
      final dep = m.group(1)!;
      checkUse(dep, relFile, 'import');
      if (_isSkin(dep) && !rules.skinRegistry.contains(relFile)) {
        out.add(
          Violation(
            relFile,
            'imports the skin $dep outside the skin registry '
            '(${rules.skinRegistry.join(', ')})',
          ),
        );
      }
    }
  }
  return out;
}
