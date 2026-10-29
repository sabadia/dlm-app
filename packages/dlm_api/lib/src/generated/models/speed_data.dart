// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'speed_data.g.dart';

@JsonSerializable()
class SpeedData {
  const SpeedData({
    required this.active,
    required this.down,
    required this.queued,
    required this.up,
  });

  factory SpeedData.fromJson(Map<String, Object?> json) =>
      _$SpeedDataFromJson(json);

  final int active;
  final int down;
  final int queued;
  final int up;

  Map<String, Object?> toJson() => _$SpeedDataToJson(this);
}
