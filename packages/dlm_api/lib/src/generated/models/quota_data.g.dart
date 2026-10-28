// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaData _$QuotaDataFromJson(Map<String, dynamic> json) => QuotaData(
  bytes: (json['bytes'] as num).toInt(),
  period: json['period'] as String,
  scope: json['scope'] as String,
  used: (json['used'] as num).toInt(),
  queueId: json['queueId'] as String?,
  resetsAt: json['resetsAt'] == null
      ? null
      : DateTime.parse(json['resetsAt'] as String),
  windowStart: json['windowStart'] == null
      ? null
      : DateTime.parse(json['windowStart'] as String),
);

Map<String, dynamic> _$QuotaDataToJson(QuotaData instance) => <String, dynamic>{
  'bytes': instance.bytes,
  'period': instance.period,
  'queueId': instance.queueId,
  'resetsAt': instance.resetsAt?.toIso8601String(),
  'scope': instance.scope,
  'used': instance.used,
  'windowStart': instance.windowStart?.toIso8601String(),
};
