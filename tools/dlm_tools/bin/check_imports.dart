import 'dart:io';

import 'package:dlm_tools/import_rules.dart';
import 'package:path/path.dart' as p;

/// Usage: dart run dlm_tools:check_imports [repository root]
void main(List<String> args) {
  final root = args.isNotEmpty ? args.first : Directory.current.path;
  final rulesFile = File(p.join(root, 'tools', 'import_rules.yaml'));
  if (!rulesFile.existsSync()) {
    stderr.writeln(
      '${rulesFile.path} not found; run from the repository root.',
    );
    exit(2);
  }
  final violations = checkWorkspace(
    root,
    ImportRules.parse(rulesFile.readAsStringSync()),
  );
  if (violations.isEmpty) {
    stdout.writeln('import rules: ok');
    return;
  }
  stderr
    ..writeln('import rules: ${violations.length} violation(s)')
    ..writeln(violations.join('\n'));
  exit(1);
}
