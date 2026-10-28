// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'health_output_body_status.dart';

part 'health_output_body.g.dart';

@JsonSerializable()
class HealthOutputBody {
  const HealthOutputBody({
    required this.apiVersion,
    required this.authenticated,
    required this.minClientApi,
    required this.status,
    required this.version,
    this.schema,
  });

  factory HealthOutputBody.fromJson(Map<String, Object?> json) =>
      _$HealthOutputBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Version of the REST API (grows only on breaking changes).
  final int apiVersion;

  /// Whether the request presented a valid bearer token.
  final bool authenticated;

  /// Oldest API version a client may have been written for; older clients must be updated.
  final int minClientApi;

  /// Always "ok" when the daemon is serving.
  final HealthOutputBodyStatus status;

  /// Daemon version.
  final String version;

  Map<String, Object?> toJson() => _$HealthOutputBodyToJson(this);
}
