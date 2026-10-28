// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_deleted_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueDeletedEvent _$QueueDeletedEventFromJson(Map<String, dynamic> json) =>
    QueueDeletedEvent(
      data: Queue.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: QueueDeletedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$QueueDeletedEventToJson(QueueDeletedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$QueueDeletedEventTypeEnumMap[instance.type]!,
    };

const _$QueueDeletedEventTypeEnumMap = {
  QueueDeletedEventType.undefined0: 'queue.deleted',
  QueueDeletedEventType.$unknown: r'$unknown',
};
