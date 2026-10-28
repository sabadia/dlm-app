// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_deleted_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskDeletedEvent _$TaskDeletedEventFromJson(Map<String, dynamic> json) =>
    TaskDeletedEvent(
      data: Task.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: TaskDeletedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$TaskDeletedEventToJson(TaskDeletedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$TaskDeletedEventTypeEnumMap[instance.type]!,
    };

const _$TaskDeletedEventTypeEnumMap = {
  TaskDeletedEventType.undefined0: 'task.deleted',
  TaskDeletedEventType.$unknown: r'$unknown',
};
