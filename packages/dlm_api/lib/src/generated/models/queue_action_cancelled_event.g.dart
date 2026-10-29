// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_action_cancelled_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueActionCancelledEvent _$QueueActionCancelledEventFromJson(
  Map<String, dynamic> json,
) => QueueActionCancelledEvent(
  data: ActionCancelledData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  type: QueueActionCancelledEventType.fromJson(json['type'] as String),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
);

Map<String, dynamic> _$QueueActionCancelledEventToJson(
  QueueActionCancelledEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QueueActionCancelledEventTypeEnumMap[instance.type]!,
};

const _$QueueActionCancelledEventTypeEnumMap = {
  QueueActionCancelledEventType.undefined0: 'queue.action_cancelled',
  QueueActionCancelledEventType.$unknown: r'$unknown',
};
