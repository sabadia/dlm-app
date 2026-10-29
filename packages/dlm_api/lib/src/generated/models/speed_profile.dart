// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'time_window.dart';

part 'speed_profile.g.dart';

@JsonSerializable()
class SpeedProfile {
  const SpeedProfile({
    required this.speedLimit,
    required this.windows,
    this.timezone,
  });

  factory SpeedProfile.fromJson(Map<String, Object?> json) =>
      _$SpeedProfileFromJson(json);

  final int speedLimit;
  final String? timezone;
  final List<TimeWindow>? windows;

  Map<String, Object?> toJson() => _$SpeedProfileToJson(this);
}
