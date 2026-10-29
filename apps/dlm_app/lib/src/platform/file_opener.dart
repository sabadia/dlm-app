import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a downloaded file, or its folder, in the system's own program.
abstract interface class FileOpener {
  /// Opens [path] with the program the system chose for it.
  Future<void> open(String path);

  /// Shows [path] in the file manager, selected where the system can.
  Future<void> reveal(String path);
}

/// [FileOpener] through `open`, `explorer` and `xdg-open`.
class ProcessFileOpener implements FileOpener {
  /// Creates the opener. [run] and [os] exist for tests.
  const ProcessFileOpener({
    Future<ProcessResult> Function(String, List<String>) run = Process.run,
    this.os,
  }) : _run = run;

  final Future<ProcessResult> Function(String, List<String>) _run;

  /// `macos`, `windows` or `linux`; the running system by default.
  final String? os;

  String get _os => os ?? Platform.operatingSystem;

  @override
  Future<void> open(String path) async {
    await switch (_os) {
      'macos' => _run('open', [path]),
      'windows' => _run('explorer', [path]),
      _ => _run('xdg-open', [path]),
    };
  }

  @override
  Future<void> reveal(String path) async {
    await switch (_os) {
      'macos' => _run('open', ['-R', path]),
      'windows' => _run('explorer', ['/select,$path']),
      // No standard way to select a file: open its folder.
      _ => _run('xdg-open', [_parent(path)]),
    };
  }

  static String _parent(String path) {
    final i = path.lastIndexOf('/');
    return i <= 0 ? '/' : path.substring(0, i);
  }
}

/// How files are opened; tests override it.
final fileOpenerProvider = Provider<FileOpener>(
  (ref) => const ProcessFileOpener(),
);
