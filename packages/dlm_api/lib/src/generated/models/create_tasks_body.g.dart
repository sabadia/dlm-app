// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTasksBody _$CreateTasksBodyFromJson(Map<String, dynamic> json) =>
    CreateTasksBody(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CreateTaskBody.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
      expandPatterns: json['expandPatterns'] as bool?,
    );

Map<String, dynamic> _$CreateTasksBodyToJson(CreateTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'expandPatterns': instance.expandPatterns,
      'items': instance.items,
    };
