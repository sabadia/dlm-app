// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_speed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemSpeedEvent _$SystemSpeedEventFromJson(Map<String, dynamic> json) =>
    SystemSpeedEvent(
      data: SpeedData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: SystemSpeedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$SystemSpeedEventToJson(SystemSpeedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$SystemSpeedEventTypeEnumMap[instance.type]!,
    };

const _$SystemSpeedEventTypeEnumMap = {
  SystemSpeedEventType.undefined0: 'system.speed',
  SystemSpeedEventType.$unknown: r'$unknown',
};
