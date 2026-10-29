import 'dart:convert';
import 'dart:io';

import 'package:dlm_tools/contract.dart';

/// Usage: dart run dlm_tools:check_contract <pinned.json> <latest.json>
///
/// Exits 1 when the newer daemon API dropped something the app uses; prints
/// what was added too. The nightly contract job runs it on the newest release.
void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: check_contract <pinned openapi> <latest openapi>');
    exit(2);
  }
  Map<String, Object?> read(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  final report = compareContracts(read(args[0]), read(args[1]));
  for (final r in report.removed) {
    stdout.writeln('REMOVED  $r');
  }
  for (final c in report.changed) {
    stdout.writeln('CHANGED  $c');
  }
  for (final a in report.added) {
    stdout.writeln('added    $a');
  }
  stdout.writeln(
    report.breaking
        ? 'contract: BREAKING (${report.removed.length} removed, '
              '${report.changed.length} changed)'
        : 'contract: compatible (${report.added.length} new operations)',
  );
  if (report.breaking) exit(1);
}
