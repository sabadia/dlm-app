import 'dart:convert';
import 'dart:io';

/// What a running daemon publishes in `<home>/config/runtime.json`.
class RuntimeInfo {
  /// Creates the value.
  const RuntimeInfo({
    required this.pid,
    required this.url,
    required this.version,
    this.apiVersion = 0,
  });

  /// Decodes the file; throws [FormatException] when it is not a runtime file.
  factory RuntimeInfo.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('runtime.json is not an object');
    }
    final pid = json['pid'];
    final url = json['url'];
    final version = json['version'];
    if (pid is! int || url is! String || version is! String) {
      throw const FormatException('runtime.json lacks pid, url or version');
    }
    final api = json['apiVersion'];
    return RuntimeInfo(
      pid: pid,
      url: url,
      version: version,
      apiVersion: api is int ? api : 0,
    );
  }

  /// Process id of the daemon.
  final int pid;

  /// Base URL of its API.
  final String url;

  /// Daemon version.
  final String version;

  /// REST API revision.
  final int apiVersion;

  /// Reads the file of the daemon whose home is [home]; null when it does not
  /// exist or is not readable (the daemon writes it atomically, so a partial
  /// file only appears when something else wrote it).
  static RuntimeInfo? read(String home) {
    final file = File(runtimePath(home));
    try {
      return RuntimeInfo.fromJson(jsonDecode(file.readAsStringSync()));
    } on Object {
      return null;
    }
  }

  /// `<home>/config/runtime.json`.
  static String runtimePath(String home) =>
      '$home${Platform.pathSeparator}config${Platform.pathSeparator}runtime.json';

  /// `<home>/config/token`.
  static String tokenPath(String home) =>
      '$home${Platform.pathSeparator}config${Platform.pathSeparator}token';

  @override
  String toString() => 'RuntimeInfo(pid: $pid, $url, $version)';
}
