// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'system_paths.dart';
import 'tool_status.dart';

part 'system_info.g.dart';

@JsonSerializable()
class SystemInfo {
  const SystemInfo({
    required this.address,
    required this.apiVersion,
    required this.arch,
    required this.databaseBytes,
    required this.engines,
    required this.goVersion,
    required this.local,
    required this.minClientApi,
    required this.os,
    required this.paths,
    required this.pid,
    required this.startedAt,
    required this.tls,
    required this.tools,
    required this.uptimeSeconds,
    required this.version,
    this.schema,
    this.commit,
  });

  factory SystemInfo.fromJson(Map<String, Object?> json) =>
      _$SystemInfoFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// host:port the daemon listens on.
  final String address;

  /// Version of the REST API.
  final int apiVersion;

  /// CPU architecture.
  final String arch;

  /// Source revision the daemon was built from.
  final String? commit;

  /// Size of the database file.
  final int databaseBytes;

  /// Enabled download engines.
  final List<String>? engines;

  /// Go toolchain the daemon was built with.
  final String goVersion;

  /// Whether this request came from the machine the daemon runs on.
  final bool local;

  /// Oldest API version a client may have been written for.
  final int minClientApi;

  /// Operating system.
  final String os;
  final SystemPaths paths;

  /// Process id of the daemon.
  final int pid;

  /// When the daemon started.
  final DateTime startedAt;

  /// Whether the API is served over TLS.
  final bool tls;

  /// External programs dlm can use.
  final List<ToolStatus>? tools;

  /// Seconds since the daemon started.
  final int uptimeSeconds;

  /// Daemon version.
  final String version;

  Map<String, Object?> toJson() => _$SystemInfoToJson(this);
}
