// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'speed_override.g.dart';

@JsonSerializable()
class SpeedOverride {
  const SpeedOverride({required this.speedLimit, required this.until});

  factory SpeedOverride.fromJson(Map<String, Object?> json) =>
      _$SpeedOverrideFromJson(json);

  final int speedLimit;
  final DateTime until;

  Map<String, Object?> toJson() => _$SpeedOverrideToJson(this);
}
