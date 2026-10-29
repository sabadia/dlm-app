// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'result.dart';

part 'native_host_status.g.dart';

@JsonSerializable()
class NativeHostStatus {
  const NativeHostStatus({
    required this.allowedOrigins,
    required this.browsers,
    required this.launcher,
    required this.launcherExists,
    this.schema,
  });

  factory NativeHostStatus.fromJson(Map<String, Object?> json) =>
      _$NativeHostStatusFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The chrome-extension:// origins the daemon accepts (server.allowed_origins); an extension outside the list is refused.
  final List<String>? allowedOrigins;

  /// Per browser: whether the host is registered (installed or absent) and where.
  final List<Result>? browsers;

  /// The script browsers start; the manifests point to it.
  final String launcher;
  final bool launcherExists;

  Map<String, Object?> toJson() => _$NativeHostStatusToJson(this);
}
