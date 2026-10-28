// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_selector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskSelector _$TaskSelectorFromJson(Map<String, dynamic> json) => TaskSelector(
  schema: json[r'$schema'] as String?,
  filter: json['filter'] == null
      ? null
      : TaskSelectorFilter.fromJson(json['filter'] as Map<String, dynamic>),
  ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$TaskSelectorToJson(TaskSelector instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'filter': instance.filter,
      'ids': instance.ids,
    };
