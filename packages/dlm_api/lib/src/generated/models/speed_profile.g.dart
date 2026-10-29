// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeedProfile _$SpeedProfileFromJson(Map<String, dynamic> json) => SpeedProfile(
  speedLimit: (json['speedLimit'] as num).toInt(),
  windows: (json['windows'] as List<dynamic>?)
      ?.map((e) => TimeWindow.fromJson(e as Map<String, dynamic>))
      .toList(),
  timezone: json['timezone'] as String?,
);

Map<String, dynamic> _$SpeedProfileToJson(SpeedProfile instance) =>
    <String, dynamic>{
      'speedLimit': instance.speedLimit,
      'timezone': instance.timezone,
      'windows': instance.windows,
    };
