import 'dart:io';

import 'package:dlm_tools/workspace.dart';
import 'package:path/path.dart' as p;

/// Usage: dart run dlm_tools:test_all [flutter/dart test arguments]
///
/// Runs the tests of every workspace member that has a `test/` directory,
/// with `flutter test` or `dart test` as the member needs, and fails if any
/// run fails. Members without tests are listed and skipped.
Future<void> main(List<String> args) async {
  final root = Directory.current.path;
  var failed = 0;
  var ran = 0;
  for (final m in workspaceMembers(root)) {
    if (!m.hasTests) {
      stdout.writeln('-- ${m.name}: no tests');
      continue;
    }
    final cmd = testCommand(m, args);
    stdout.writeln('-- ${m.name}: ${cmd.join(' ')}');
    final proc = await Process.start(
      cmd.first,
      cmd.skip(1).toList(),
      workingDirectory: p.join(root, m.dir),
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    ran++;
    if (await proc.exitCode != 0) failed++;
  }
  stdout.writeln('-- $ran package(s) tested, $failed failed');
  if (failed > 0) exit(1);
}
