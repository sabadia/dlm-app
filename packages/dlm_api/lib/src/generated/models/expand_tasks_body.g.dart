// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expand_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpandTasksBody _$ExpandTasksBodyFromJson(Map<String, dynamic> json) =>
    ExpandTasksBody(
      pattern: json['pattern'] as String,
      schema: json[r'$schema'] as String?,
      preview: (json['preview'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExpandTasksBodyToJson(ExpandTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'pattern': instance.pattern,
      'preview': instance.preview,
    };
