import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('follows each system convention', () {
    expect(
      AppDirs.resolve(
        environment: {'HOME': '/Users/a'},
        operatingSystem: 'macos',
      ).root,
      '/Users/a/Library/Application Support/dlm',
    );
    expect(
      AppDirs.resolve(
        environment: {'LocalAppData': r'C:\Users\a\AppData\Local'},
        operatingSystem: 'windows',
      ).root,
      r'C:\Users\a\AppData\Local\dlm',
    );
    expect(
      AppDirs.resolve(
        environment: {'USERPROFILE': r'C:\Users\a'},
        operatingSystem: 'windows',
      ).root,
      r'C:\Users\a\AppData\Local\dlm',
    );
    expect(
      AppDirs.resolve(
        environment: {'HOME': '/home/a'},
        operatingSystem: 'linux',
      ).root,
      '/home/a/.local/share/dlm',
    );
    expect(
      AppDirs.resolve(
        environment: {'HOME': '/home/a', 'XDG_DATA_HOME': '/data'},
        operatingSystem: 'linux',
      ).root,
      '/data/dlm',
    );
    expect(
      AppDirs.resolve(
        environment: {'HOME': '/home/a', 'XDG_DATA_HOME': 'relative'},
        operatingSystem: 'linux',
      ).root,
      '/home/a/.local/share/dlm',
      reason: 'a relative XDG path is ignored, as the specification says',
    );
  });

  test('a missing home is an error, not a guess', () {
    expect(
      () => AppDirs.resolve(environment: {}, operatingSystem: 'macos'),
      throwsStateError,
    );
    expect(
      () => AppDirs.resolve(environment: {}, operatingSystem: 'windows'),
      throwsStateError,
    );
  });

  test('the files and the daemon home live below the root', () {
    const dirs = AppDirs('/r');
    expect(dirs.daemonHome, endsWith('daemon'));
    expect(dirs.logs, endsWith('logs'));
    expect(dirs.preferencesFile, endsWith('preferences.json'));
    expect(dirs.profilesFile, endsWith('profiles.json'));
    expect(
      {
        dirs.daemonHome,
        dirs.logs,
        dirs.preferencesFile,
        dirs.profilesFile,
      }.length,
      4,
    );
  });
}
