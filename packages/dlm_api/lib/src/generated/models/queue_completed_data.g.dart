// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_completed_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueCompletedData _$QueueCompletedDataFromJson(Map<String, dynamic> json) =>
    QueueCompletedData(
      action: json['action'] as String,
      completedTasks: (json['completedTasks'] as num).toInt(),
      executeAt: DateTime.parse(json['executeAt'] as String),
    );

Map<String, dynamic> _$QueueCompletedDataToJson(QueueCompletedData instance) =>
    <String, dynamic>{
      'action': instance.action,
      'completedTasks': instance.completedTasks,
      'executeAt': instance.executeAt.toIso8601String(),
    };
