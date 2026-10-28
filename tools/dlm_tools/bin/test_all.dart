import 'dart:convert';
import 'dart:io';

import 'package:dlm_tools/workspace.dart';
import 'package:path/path.dart' as p;

/// Usage: dart run dlm_tools:test_all [--allow-empty] [test arguments]
///
/// Runs the tests of every workspace member that has a `test/` directory,
/// with `flutter test` or `dart test` as the member needs, and fails if any
/// run fails. Members without tests are listed and skipped. With
/// `--allow-empty` a run that found no test matching the selectors (for
/// example `--tags golden` before the first golden test exists) is a pass.
Future<void> main(List<String> args) async {
  final allowEmpty = args.contains('--allow-empty');
  final testArgs = args.where((a) => a != '--allow-empty').toList();
  final root = Directory.current.path;
  var failed = 0;
  var ran = 0;
  for (final m in workspaceMembers(root)) {
    if (!m.hasTests) {
      stdout.writeln('-- ${m.name}: no tests');
      continue;
    }
    final cmd = testCommand(m, testArgs);
    stdout.writeln('-- ${m.name}: ${cmd.join(' ')}');
    final proc = await Process.start(
      cmd.first,
      cmd.skip(1).toList(),
      workingDirectory: p.join(root, m.dir),
      runInShell: Platform.isWindows,
    );
    final out = StringBuffer();
    Future<void> pump(Stream<List<int>> s, IOSink sink) =>
        s.transform(utf8.decoder).forEach((chunk) {
          sink.write(chunk);
          out.write(chunk);
        });
    await Future.wait([pump(proc.stdout, stdout), pump(proc.stderr, stderr)]);
    ran++;
    final code = await proc.exitCode;
    final empty = RegExp('No tests (match|ran)').hasMatch(out.toString());
    if (code != 0 && !(allowEmpty && empty)) failed++;
  }
  stdout.writeln('-- $ran package(s) tested, $failed failed');
  if (failed > 0) exit(1);
}
