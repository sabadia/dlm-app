// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_output_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthOutputBody _$HealthOutputBodyFromJson(Map<String, dynamic> json) =>
    HealthOutputBody(
      apiVersion: (json['apiVersion'] as num).toInt(),
      authenticated: json['authenticated'] as bool,
      minClientApi: (json['minClientApi'] as num).toInt(),
      status: HealthOutputBodyStatus.fromJson(json['status'] as String),
      version: json['version'] as String,
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$HealthOutputBodyToJson(HealthOutputBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'apiVersion': instance.apiVersion,
      'authenticated': instance.authenticated,
      'minClientApi': instance.minClientApi,
      'status': _$HealthOutputBodyStatusEnumMap[instance.status]!,
      'version': instance.version,
    };

const _$HealthOutputBodyStatusEnumMap = {
  HealthOutputBodyStatus.ok: 'ok',
  HealthOutputBodyStatus.$unknown: r'$unknown',
};
