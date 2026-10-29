// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quota.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quota _$QuotaFromJson(Map<String, dynamic> json) => Quota(
  bytes: (json['bytes'] as num).toInt(),
  period: json['period'] as String,
);

Map<String, dynamic> _$QuotaToJson(Quota instance) => <String, dynamic>{
  'bytes': instance.bytes,
  'period': instance.period,
};
