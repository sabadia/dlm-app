// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_stats_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EngineStatsBody _$EngineStatsBodyFromJson(Map<String, dynamic> json) =>
    EngineStatsBody(
      downloadedBytes: (json['downloadedBytes'] as num).toInt(),
      engine: json['engine'] as String,
      tasks: (json['tasks'] as num).toInt(),
    );

Map<String, dynamic> _$EngineStatsBodyToJson(EngineStatsBody instance) =>
    <String, dynamic>{
      'downloadedBytes': instance.downloadedBytes,
      'engine': instance.engine,
      'tasks': instance.tasks,
    };
