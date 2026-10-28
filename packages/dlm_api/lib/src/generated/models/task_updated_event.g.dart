// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_updated_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskUpdatedEvent _$TaskUpdatedEventFromJson(Map<String, dynamic> json) =>
    TaskUpdatedEvent(
      data: Task.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: TaskUpdatedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$TaskUpdatedEventToJson(TaskUpdatedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$TaskUpdatedEventTypeEnumMap[instance.type]!,
    };

const _$TaskUpdatedEventTypeEnumMap = {
  TaskUpdatedEventType.undefined0: 'task.updated',
  TaskUpdatedEventType.$unknown: r'$unknown',
};
