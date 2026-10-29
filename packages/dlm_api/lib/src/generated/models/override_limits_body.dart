// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'override_limits_body.g.dart';

@JsonSerializable()
class OverrideLimitsBody {
  const OverrideLimitsBody({
    required this.minutes,
    required this.speedLimit,
    this.schema,
  });

  factory OverrideLimitsBody.fromJson(Map<String, Object?> json) =>
      _$OverrideLimitsBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// How long the override lasts, in minutes (1 to 1440); the configured limit applies again afterwards.
  final int minutes;

  /// Global speed limit in bytes per second while the override lasts; 0 is unlimited (turbo).
  final int speedLimit;

  Map<String, Object?> toJson() => _$OverrideLimitsBodyToJson(this);
}
