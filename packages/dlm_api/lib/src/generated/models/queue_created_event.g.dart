// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_created_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueCreatedEvent _$QueueCreatedEventFromJson(Map<String, dynamic> json) =>
    QueueCreatedEvent(
      data: Queue.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: QueueCreatedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$QueueCreatedEventToJson(QueueCreatedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$QueueCreatedEventTypeEnumMap[instance.type]!,
    };

const _$QueueCreatedEventTypeEnumMap = {
  QueueCreatedEventType.undefined0: 'queue.created',
  QueueCreatedEventType.$unknown: r'$unknown',
};
