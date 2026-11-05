// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskError _$TaskErrorFromJson(Map<String, dynamic> json) => TaskError(
  at: DateTime.parse(json['at'] as String),
  code: json['code'] as String,
  message: json['message'] as String,
  retryable: json['retryable'] as bool,
  retry: json['retry'] == null
      ? null
      : TaskRetry.fromJson(json['retry'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskErrorToJson(TaskError instance) => <String, dynamic>{
  'at': instance.at.toIso8601String(),
  'code': instance.code,
  'message': instance.message,
  'retry': instance.retry,
  'retryable': instance.retryable,
};
