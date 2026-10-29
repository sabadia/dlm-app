// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelinePoint _$TimelinePointFromJson(Map<String, dynamic> json) =>
    TimelinePoint(
      down: (json['down'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      up: (json['up'] as num).toInt(),
      group: json['group'] as String?,
    );

Map<String, dynamic> _$TimelinePointToJson(TimelinePoint instance) =>
    <String, dynamic>{
      'down': instance.down,
      'group': instance.group,
      'time': instance.time.toIso8601String(),
      'up': instance.up,
    };
