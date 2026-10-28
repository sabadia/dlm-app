// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota_exhausted_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaExhaustedEvent _$QuotaExhaustedEventFromJson(Map<String, dynamic> json) =>
    QuotaExhaustedEvent(
      data: QuotaData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: QuotaExhaustedEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$QuotaExhaustedEventToJson(
  QuotaExhaustedEvent instance,
) => <String, dynamic>{
  'data': instance.data,
  'id': instance.id,
  'queueId': instance.queueId,
  'taskId': instance.taskId,
  'time': instance.time.toIso8601String(),
  'type': _$QuotaExhaustedEventTypeEnumMap[instance.type]!,
};

const _$QuotaExhaustedEventTypeEnumMap = {
  QuotaExhaustedEventType.undefined0: 'quota.exhausted',
  QuotaExhaustedEventType.$unknown: r'$unknown',
};
