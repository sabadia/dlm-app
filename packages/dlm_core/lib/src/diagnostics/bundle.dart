import 'dart:convert';

import '../connection/profile.dart';
import 'app_logger.dart';
import 'redactor.dart';

/// Builds what the "copy diagnostics" button puts on the clipboard: everything
/// support needs, nothing that is secret.
/// [daemonInfo] is the daemon's `system info` as a JSON
/// object when connected. Every line passes through [redactor].
String buildDiagnostics({
  required Redactor redactor,
  required String appVersion,
  required String operatingSystem,
  required List<ConnectionProfile> profiles,
  required AppLogger logger,
  String? locale,
  Map<String, Object?>? daemonInfo,
  String? activeProfileId,
  DateTime? now,
}) {
  final out = StringBuffer()
    ..writeln('dlm app diagnostics')
    ..writeln('generated: ${(now ?? DateTime.now()).toUtc().toIso8601String()}')
    ..writeln('app: $appVersion')
    ..writeln('os: $operatingSystem')
    ..writeln('locale: ${locale ?? 'unknown'}')
    ..writeln()
    ..writeln('connections:');
  for (final p in profiles) {
    final active = p.id == activeProfileId ? ' (active)' : '';
    final where = p.isLocal ? 'managed daemon' : _hostOf(p.url);
    final tls = p.tlsPin == null ? '' : ', certificate pinned';
    out.writeln('- ${p.name}$active: ${p.kind.name}, $where$tls');
  }
  out
    ..writeln()
    ..writeln('daemon:');
  if (daemonInfo == null) {
    out.writeln('not connected');
  } else {
    out.writeln(const JsonEncoder.withIndent('  ').convert(daemonInfo));
  }
  out
    ..writeln()
    ..writeln('recent log:');
  for (final line in logger.recent) {
    out.writeln(line);
  }
  return redactor.redact(out.toString());
}

/// `host:port` of [url] without credentials, path or query.
String _hostOf(String? url) {
  final uri = url == null ? null : Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return 'invalid address';
  return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
}
