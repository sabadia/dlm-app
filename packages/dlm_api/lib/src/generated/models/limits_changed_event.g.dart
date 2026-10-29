// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limits_changed_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LimitsChangedEvent _$LimitsChangedEventFromJson(Map<String, dynamic> json) =>
    LimitsChangedEvent(
      data: LimitsChangedData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: LimitsChangedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$LimitsChangedEventToJson(LimitsChangedEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$LimitsChangedEventTypeEnumMap[instance.type]!,
    };

const _$LimitsChangedEventTypeEnumMap = {
  LimitsChangedEventType.undefined0: 'limits.changed',
  LimitsChangedEventType.$unknown: r'$unknown',
};
