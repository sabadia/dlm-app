// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_refresh_requested_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRefreshRequestedEvent _$TaskRefreshRequestedEventFromJson(
  Map<String, dynamic> json,
) => TaskRefreshRequestedEvent(
  data: RefreshRequestedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  type: TaskRefreshRequestedEventType.fromJson(json['type'] as String),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
);

Map<String, dynamic> _$TaskRefreshRequestedEventToJson(
  TaskRefreshRequestedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$TaskRefreshRequestedEventTypeEnumMap[instance.type]!,
};

const _$TaskRefreshRequestedEventTypeEnumMap = {
  TaskRefreshRequestedEventType.undefined0: 'task.refresh.requested',
  TaskRefreshRequestedEventType.$unknown: r'$unknown',
};
