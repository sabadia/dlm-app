// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_window.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeWindow _$TimeWindowFromJson(Map<String, dynamic> json) => TimeWindow(
  days: (json['days'] as List<dynamic>?)?.map((e) => e as String).toList(),
  end: json['end'] as String,
  start: json['start'] as String,
);

Map<String, dynamic> _$TimeWindowToJson(TimeWindow instance) =>
    <String, dynamic>{
      'days': instance.days,
      'end': instance.end,
      'start': instance.start,
    };
