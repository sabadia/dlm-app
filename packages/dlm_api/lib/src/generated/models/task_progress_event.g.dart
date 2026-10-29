// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_progress_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskProgressEvent _$TaskProgressEventFromJson(Map<String, dynamic> json) =>
    TaskProgressEvent(
      data: ProgressData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: TaskProgressEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$TaskProgressEventToJson(TaskProgressEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$TaskProgressEventTypeEnumMap[instance.type]!,
    };

const _$TaskProgressEventTypeEnumMap = {
  TaskProgressEventType.undefined0: 'task.progress',
  TaskProgressEventType.$unknown: r'$unknown',
};
