// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota_reset_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaResetEvent _$QuotaResetEventFromJson(Map<String, dynamic> json) =>
    QuotaResetEvent(
      data: QuotaData.fromJson(json['data'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      type: QuotaResetEventType.fromJson(json['type'] as String),
      queueId: json['queueId'] as String?,
      taskId: json['taskId'] as String?,
    );

Map<String, dynamic> _$QuotaResetEventToJson(QuotaResetEvent instance) =>
    <String, dynamic>{
      'data': instance.data,
      'id': instance.id,
      'queueId': instance.queueId,
      'taskId': instance.taskId,
      'time': instance.time.toIso8601String(),
      'type': _$QuotaResetEventTypeEnumMap[instance.type]!,
    };

const _$QuotaResetEventTypeEnumMap = {
  QuotaResetEventType.undefined0: 'quota.reset',
  QuotaResetEventType.$unknown: r'$unknown',
};
