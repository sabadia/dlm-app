import 'package:dlm_app/src/platform/app_restart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens the bundle on macOS after the app has exited', () {
    final cmd = relaunchCommand(
      pid: 4242,
      executable: "/Applications/DLM's.app/Contents/MacOS/DLM",
      operatingSystem: 'macos',
    );
    expect(cmd.exe, '/bin/sh');
    final script = cmd.args.last;
    expect(script, contains('kill -0 4242'));
    // The bundle, not the executable inside it, and a quote in the path is
    // escaped, not left to end the string.
    expect(script, contains("open -n '/Applications/DLM'\\''s.app'"));
  });

  test('starts a bare executable directly on Linux', () {
    final cmd = relaunchCommand(
      pid: 7,
      executable: '/opt/dlm/dlm',
      operatingSystem: 'linux',
    );
    expect(cmd.exe, '/bin/sh');
    expect(cmd.args.last, endsWith("; '/opt/dlm/dlm'"));
  });

  test('waits for the process and starts it with PowerShell on Windows', () {
    final cmd = relaunchCommand(
      pid: 99,
      executable: r'C:\Program Files\DLM\dlm.exe',
      operatingSystem: 'windows',
    );
    expect(cmd.exe, 'powershell');
    expect(cmd.args.last, contains('Wait-Process -Id 99'));
    expect(cmd.args.last, contains(r"'C:\Program Files\DLM\dlm.exe'"));
  });
}
