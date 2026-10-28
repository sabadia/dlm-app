// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_created_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCreatedEvent _$TaskCreatedEventFromJson(Map<String, dynamic> json) =>
    TaskCreatedEvent(
      data: Task.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: TaskCreatedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$TaskCreatedEventToJson(TaskCreatedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$TaskCreatedEventTypeEnumMap[instance.type]!,
    };

const _$TaskCreatedEventTypeEnumMap = {
  TaskCreatedEventType.undefined0: 'task.created',
  TaskCreatedEventType.$unknown: r'$unknown',
};
