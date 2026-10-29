import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a web page in the system's browser.
abstract interface class UrlOpener {
  /// Opens [url]. Returns false, and opens nothing, unless it is an `http` or
  /// `https` address: the address comes from a web page, and anything else
  /// could start another program.
  Future<bool> open(String url);
}

/// [UrlOpener] through `open`, `explorer` and `xdg-open`, which are given the
/// address as one argument and never through a shell.
class ProcessUrlOpener implements UrlOpener {
  /// Creates the opener. [run] and [os] exist for tests.
  const ProcessUrlOpener({
    Future<ProcessResult> Function(String, List<String>) run = Process.run,
    this.os,
  }) : _run = run;

  final Future<ProcessResult> Function(String, List<String>) _run;

  /// `macos`, `windows` or `linux`; the running system by default.
  final String? os;

  @override
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return false;
    }
    final address = uri.toString();
    await switch (os ?? Platform.operatingSystem) {
      'macos' => _run('open', [address]),
      'windows' => _run('explorer', [address]),
      _ => _run('xdg-open', [address]),
    };
    return true;
  }
}

/// How web pages are opened; tests override it.
final urlOpenerProvider = Provider<UrlOpener>(
  (ref) => const ProcessUrlOpener(),
);
