// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'speed_override.dart';

part 'limits_changed_data.g.dart';

@JsonSerializable()
class LimitsChangedData {
  const LimitsChangedData({required this.speedLimit, this.override});

  factory LimitsChangedData.fromJson(Map<String, Object?> json) =>
      _$LimitsChangedDataFromJson(json);

  final SpeedOverride? override;
  final int speedLimit;

  Map<String, Object?> toJson() => _$LimitsChangedDataToJson(this);
}
