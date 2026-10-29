// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_status_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskStatusEvent _$TaskStatusEventFromJson(Map<String, dynamic> json) =>
    TaskStatusEvent(
      data: StatusData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: TaskStatusEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$TaskStatusEventToJson(TaskStatusEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$TaskStatusEventTypeEnumMap[instance.type]!,
    };

const _$TaskStatusEventTypeEnumMap = {
  TaskStatusEventType.undefined0: 'task.status',
  TaskStatusEventType.$unknown: r'$unknown',
};
