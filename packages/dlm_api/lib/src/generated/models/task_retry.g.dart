// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_retry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRetry _$TaskRetryFromJson(Map<String, dynamic> json) => TaskRetry(
  attempt: (json['attempt'] as num).toInt(),
  max: (json['max'] as num).toInt(),
  nextAt: DateTime.parse(json['nextAt'] as String),
);

Map<String, dynamic> _$TaskRetryToJson(TaskRetry instance) => <String, dynamic>{
  'attempt': instance.attempt,
  'max': instance.max,
  'nextAt': instance.nextAt.toIso8601String(),
};
