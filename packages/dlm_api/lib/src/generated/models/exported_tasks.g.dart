// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exported_tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportedTasks _$ExportedTasksFromJson(Map<String, dynamic> json) =>
    ExportedTasks(
      content: json['content'] as String,
      count: (json['count'] as num).toInt(),
      format: json['format'] as String,
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$ExportedTasksToJson(ExportedTasks instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'content': instance.content,
      'count': instance.count,
      'format': instance.format,
    };
