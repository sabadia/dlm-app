// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_updated_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueUpdatedEvent _$QueueUpdatedEventFromJson(Map<String, dynamic> json) =>
    QueueUpdatedEvent(
      data: Queue.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: QueueUpdatedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$QueueUpdatedEventToJson(QueueUpdatedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$QueueUpdatedEventTypeEnumMap[instance.type]!,
    };

const _$QueueUpdatedEventTypeEnumMap = {
  QueueUpdatedEventType.undefined0: 'queue.updated',
  QueueUpdatedEventType.$unknown: r'$unknown',
};
