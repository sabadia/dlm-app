// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_completed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueCompletedEvent _$QueueCompletedEventFromJson(Map<String, dynamic> json) =>
    QueueCompletedEvent(
      data: QueueCompletedData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: QueueCompletedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$QueueCompletedEventToJson(
  QueueCompletedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueCompletedEventTypeEnumMap[instance.type]!,
};

const _$QueueCompletedEventTypeEnumMap = {
  QueueCompletedEventType.undefined0: 'queue.completed',
  QueueCompletedEventType.$unknown: r'$unknown',
};
