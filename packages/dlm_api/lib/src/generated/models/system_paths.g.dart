// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_paths.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemPaths _$SystemPathsFromJson(Map<String, dynamic> json) => SystemPaths(
  cache: json['cache'] as String,
  config: json['config'] as String,
  data: json['data'] as String,
  database: json['database'] as String,
  downloads: json['downloads'] as String,
  log: json['log'] as String,
);

Map<String, dynamic> _$SystemPathsToJson(SystemPaths instance) =>
    <String, dynamic>{
      'cache': instance.cache,
      'config': instance.config,
      'data': instance.data,
      'database': instance.database,
      'downloads': instance.downloads,
      'log': instance.log,
    };
