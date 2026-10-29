import 'dart:io';

import 'package:dlm_tools/l10n_check.dart';

/// Usage: dart run dlm_tools:check_l10n
///
/// Checks the translation files of packages/dlm_l10n against app_en.arb and
/// prints how many messages each locale has not translated yet.
void main() {
  final dir = Directory('packages/dlm_l10n/lib/l10n');
  if (!dir.existsSync()) {
    stderr.writeln('run from the repository root');
    exit(2);
  }
  final result = checkArbs(dir);
  result.missing.forEach((file, n) {
    stdout.writeln('$file: $n messages not translated');
  });
  for (final p in result.problems) {
    stdout.writeln('PROBLEM $p');
  }
  stdout.writeln(
    result.problems.isEmpty
        ? 'l10n: ok'
        : 'l10n: ${result.problems.length} problem(s)',
  );
  if (result.problems.isNotEmpty) exit(1);
}
