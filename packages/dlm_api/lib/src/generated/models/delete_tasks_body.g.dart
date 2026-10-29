// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteTasksBody _$DeleteTasksBodyFromJson(Map<String, dynamic> json) =>
    DeleteTasksBody(
      schema: json[r'$schema'] as String?,
      files: json['files'] as bool?,
      filter: json['filter'] == null
          ? null
          : TaskSelectorFilter.fromJson(json['filter'] as Map<String, dynamic>),
      ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DeleteTasksBodyToJson(DeleteTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'files': instance.files,
      'filter': instance.filter,
      'ids': instance.ids,
    };
