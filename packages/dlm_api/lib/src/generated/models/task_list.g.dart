// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskList _$TaskListFromJson(Map<String, dynamic> json) => TaskList(
  tasks: (json['tasks'] as List<dynamic>?)
      ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
  nextCursor: json['nextCursor'] as String?,
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$TaskListToJson(TaskList instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'nextCursor': instance.nextCursor,
  'tasks': instance.tasks,
  'total': instance.total,
};
