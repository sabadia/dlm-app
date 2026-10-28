// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_refresh_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRefreshEvent _$TaskRefreshEventFromJson(Map<String, dynamic> json) =>
    TaskRefreshEvent(
      data: RefreshAttempt.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: TaskRefreshEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$TaskRefreshEventToJson(TaskRefreshEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$TaskRefreshEventTypeEnumMap[instance.type]!,
    };

const _$TaskRefreshEventTypeEnumMap = {
  TaskRefreshEventType.undefined0: 'task.refresh',
  TaskRefreshEventType.$unknown: r'$unknown',
};
