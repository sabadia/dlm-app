// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Running _$RunningFromJson(Map<String, dynamic> json) => Running(
  group: json['group'] as String,
  sessions: (json['sessions'] as num).toInt(),
);

Map<String, dynamic> _$RunningToJson(Running instance) => <String, dynamic>{
  'group': instance.group,
  'sessions': instance.sessions,
};
