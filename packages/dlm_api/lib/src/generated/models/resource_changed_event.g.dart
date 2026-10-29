// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_changed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceChangedEvent _$ResourceChangedEventFromJson(
  Map<String, dynamic> json,
) => ResourceChangedEvent(
  data: ResourceChangedData.fromJson(json['data'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  type: ResourceChangedEventType.fromJson(json['type'] as String),
  queueId: json['queueId'] as String?,
  taskId: json['taskId'] as String?,
);

Map<String, dynamic> _$ResourceChangedEventToJson(
  ResourceChangedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$ResourceChangedEventTypeEnumMap[instance.type]!,
};

const _$ResourceChangedEventTypeEnumMap = {
  ResourceChangedEventType.undefined0: 'resource.changed',
  ResourceChangedEventType.$unknown: r'$unknown',
};
