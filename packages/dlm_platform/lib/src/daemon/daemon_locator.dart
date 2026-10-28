import 'dart:io';

/// Finds the `dlm` executable to run.
class DaemonLocator {
  /// Creates a locator. The arguments exist for tests.
  const DaemonLocator({
    this.environment,
    this.executable,
    this.operatingSystem,
    this.exists = _fileExists,
  });

  /// Environment to read `DLM_DAEMON` and `PATH` from (default: the process').
  final Map<String, String>? environment;

  /// The app's own executable (default: [Platform.resolvedExecutable]).
  final String? executable;

  /// `macos`, `windows` or `linux` (default: the running one).
  final String? operatingSystem;

  /// File existence check.
  final bool Function(String path) exists;

  static bool _fileExists(String path) => File(path).existsSync();

  /// The places the daemon may be, best first: the `DLM_DAEMON` override, the
  /// copy bundled with the app, then `dlm` on the PATH (development).
  List<String> candidates() {
    final env = environment ?? Platform.environment;
    final os = operatingSystem ?? Platform.operatingSystem;
    final exe = executable ?? Platform.resolvedExecutable;
    final sep = os == 'windows' ? r'\' : '/';
    final dir = exe.substring(
      0,
      exe.lastIndexOf(sep) < 0 ? 0 : exe.lastIndexOf(sep),
    );
    final name = os == 'windows' ? 'dlm.exe' : 'dlm';
    final out = <String>[];
    final override = env['DLM_DAEMON'];
    if (override != null && override.isNotEmpty) out.add(override);
    out.add(
      os == 'macos'
          // <App>.app/Contents/MacOS/<exe> -> <App>.app/Contents/Resources/bin
          ? '$dir/../Resources/bin/$name'
          : '$dir${sep}bin$sep$name',
    );
    final path = env[os == 'windows' ? 'Path' : 'PATH'] ?? env['PATH'] ?? '';
    final pathSep = os == 'windows' ? ';' : ':';
    for (final p in path.split(pathSep)) {
      if (p.isNotEmpty) out.add('$p$sep$name');
    }
    return out;
  }

  /// The first existing candidate, or null.
  String? find() {
    for (final c in candidates()) {
      if (exists(c)) return c;
    }
    return null;
  }
}
