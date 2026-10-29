// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_override.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeedOverride _$SpeedOverrideFromJson(Map<String, dynamic> json) =>
    SpeedOverride(
      speedLimit: (json['speedLimit'] as num).toInt(),
      until: DateTime.parse(json['until'] as String),
    );

Map<String, dynamic> _$SpeedOverrideToJson(SpeedOverride instance) =>
    <String, dynamic>{
      'speedLimit': instance.speedLimit,
      'until': instance.until.toIso8601String(),
    };
