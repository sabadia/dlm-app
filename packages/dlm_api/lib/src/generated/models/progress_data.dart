// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'progress_data.g.dart';

@JsonSerializable()
class ProgressData {
  const ProgressData({
    required this.connections,
    required this.downloaded,
    required this.size,
    required this.speed,
  });

  factory ProgressData.fromJson(Map<String, Object?> json) =>
      _$ProgressDataFromJson(json);

  final int connections;
  final int downloaded;
  final int size;
  final int speed;

  Map<String, Object?> toJson() => _$ProgressDataToJson(this);
}
