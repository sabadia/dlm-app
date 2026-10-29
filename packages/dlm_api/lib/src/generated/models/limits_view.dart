// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'scope_limits.dart';
import 'speed_override.dart';

part 'limits_view.g.dart';

@JsonSerializable()
class LimitsView {
  const LimitsView({
    required this.global,
    required this.queues,
    this.schema,
    this.override,
  });

  factory LimitsView.fromJson(Map<String, Object?> json) =>
      _$LimitsViewFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final ScopeLimits global;
  final SpeedOverride? override;
  final List<ScopeLimits>? queues;

  Map<String, Object?> toJson() => _$LimitsViewToJson(this);
}
