// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'override_limits_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverrideLimitsBody _$OverrideLimitsBodyFromJson(Map<String, dynamic> json) =>
    OverrideLimitsBody(
      minutes: (json['minutes'] as num).toInt(),
      speedLimit: (json['speedLimit'] as num).toInt(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$OverrideLimitsBodyToJson(OverrideLimitsBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'minutes': instance.minutes,
      'speedLimit': instance.speedLimit,
    };
