// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsBody _$StatsBodyFromJson(Map<String, dynamic> json) => StatsBody(
  byEngine: (json['byEngine'] as List<dynamic>?)
      ?.map((e) => EngineStatsBody.fromJson(e as Map<String, dynamic>))
      .toList(),
  byStatus: Map<String, int>.from(json['byStatus'] as Map),
  completed: (json['completed'] as List<dynamic>?)
      ?.map((e) => CompletedStatsRow.fromJson(e as Map<String, dynamic>))
      .toList(),
  downloadedBytes: (json['downloadedBytes'] as num).toInt(),
  tasks: (json['tasks'] as num).toInt(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$StatsBodyToJson(StatsBody instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'byEngine': instance.byEngine,
  'byStatus': instance.byStatus,
  'completed': instance.completed,
  'downloadedBytes': instance.downloadedBytes,
  'tasks': instance.tasks,
};
