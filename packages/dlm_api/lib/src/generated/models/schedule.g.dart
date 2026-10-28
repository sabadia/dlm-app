// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  windows: (json['windows'] as List<dynamic>?)
      ?.map((e) => TimeWindow.fromJson(e as Map<String, dynamic>))
      .toList(),
  timezone: json['timezone'] as String?,
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'timezone': instance.timezone,
  'windows': instance.windows,
};
