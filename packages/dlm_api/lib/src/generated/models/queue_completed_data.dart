// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'queue_completed_data.g.dart';

@JsonSerializable()
class QueueCompletedData {
  const QueueCompletedData({
    required this.action,
    required this.completedTasks,
    required this.executeAt,
  });

  factory QueueCompletedData.fromJson(Map<String, Object?> json) =>
      _$QueueCompletedDataFromJson(json);

  final String action;
  final int completedTasks;
  final DateTime executeAt;

  Map<String, Object?> toJson() => _$QueueCompletedDataToJson(this);
}
