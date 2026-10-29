// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotaView _$QuotaViewFromJson(Map<String, dynamic> json) => QuotaView(
  bytes: (json['bytes'] as num).toInt(),
  exhausted: json['exhausted'] as bool,
  period: json['period'] as String,
  used: (json['used'] as num).toInt(),
  resetsAt: json['resetsAt'] == null
      ? null
      : DateTime.parse(json['resetsAt'] as String),
  windowStart: json['windowStart'] == null
      ? null
      : DateTime.parse(json['windowStart'] as String),
);

Map<String, dynamic> _$QuotaViewToJson(QuotaView instance) => <String, dynamic>{
  'bytes': instance.bytes,
  'exhausted': instance.exhausted,
  'period': instance.period,
  'resetsAt': instance.resetsAt?.toIso8601String(),
  'used': instance.used,
  'windowStart': instance.windowStart?.toIso8601String(),
};
