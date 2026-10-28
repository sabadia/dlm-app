import 'dart:io';

/// Where the app keeps its files, following each system's convention:
///
/// * macOS: `~/Library/Application Support/dlm`
/// * Windows: `%LocalAppData%\dlm`
/// * Linux: `$XDG_DATA_HOME/dlm` (default `~/.local/share/dlm`)
///
/// The managed daemon lives in a subdirectory ([daemonHome]) and is started
/// with it as `--home`, so the app's data and the daemon's stay together and
/// do not mix with a daemon the user runs by hand.
class AppDirs {
  /// Creates the layout below [root].
  const AppDirs(this.root);

  /// Resolves the directory of this machine. The arguments exist for tests.
  factory AppDirs.resolve({
    Map<String, String>? environment,
    String? operatingSystem,
  }) {
    final env = environment ?? Platform.environment;
    final os = operatingSystem ?? Platform.operatingSystem;
    final home = env['HOME'] ?? env['USERPROFILE'];
    switch (os) {
      case 'windows':
        final local =
            env['LocalAppData'] ??
            (home == null ? null : '$home\\AppData\\Local');
        if (local == null) throw StateError('%LocalAppData% is not set');
        return AppDirs('$local\\dlm');
      case 'macos':
        if (home == null) throw StateError(r'$HOME is not set');
        return AppDirs('$home/Library/Application Support/dlm');
      default:
        final xdg = env['XDG_DATA_HOME'];
        if (xdg != null && xdg.startsWith('/')) return AppDirs('$xdg/dlm');
        if (home == null) throw StateError(r'$HOME is not set');
        return AppDirs('$home/.local/share/dlm');
    }
  }

  /// The app's directory.
  final String root;

  String _in(String name) => '$root${Platform.pathSeparator}$name';

  /// The managed daemon's `--home`.
  String get daemonHome => _in('daemon');

  /// Rotating app logs and crash files.
  String get logs => _in('logs');

  /// `preferences.json`.
  String get preferencesFile => _in('preferences.json');

  /// `profiles.json` (connection profiles, no secrets).
  String get profilesFile => _in('profiles.json');
}
