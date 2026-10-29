import 'dart:io';

import 'package:dlm_app/src/platform/file_opener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('files open and reveal with the program of each system', () async {
    final calls = <(String, List<String>)>[];
    Future<ProcessResult> run(String exe, List<String> args) async {
      calls.add((exe, args));
      return ProcessResult(0, 0, '', '');
    }

    final mac = ProcessFileOpener(run: run, os: 'macos');
    await mac.open('/tmp/a.bin');
    await mac.reveal('/tmp/a.bin');
    final win = ProcessFileOpener(run: run, os: 'windows');
    await win.reveal(r'C:\dl\a.bin');
    final linux = ProcessFileOpener(run: run, os: 'linux');
    await linux.reveal('/home/me/dl/a.bin');

    expect(
      [for (final (exe, args) in calls) '$exe ${args.join(' ')}'],
      [
        'open /tmp/a.bin',
        'open -R /tmp/a.bin',
        r'explorer /select,C:\dl\a.bin',
        'xdg-open /home/me/dl',
      ],
    );
  });
}
