// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeedData _$SpeedDataFromJson(Map<String, dynamic> json) => SpeedData(
  active: (json['active'] as num).toInt(),
  down: (json['down'] as num).toInt(),
  queued: (json['queued'] as num).toInt(),
  up: (json['up'] as num).toInt(),
);

Map<String, dynamic> _$SpeedDataToJson(SpeedData instance) => <String, dynamic>{
  'active': instance.active,
  'down': instance.down,
  'queued': instance.queued,
  'up': instance.up,
};
