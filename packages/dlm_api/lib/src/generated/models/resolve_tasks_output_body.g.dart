// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_tasks_output_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveTasksOutputBody _$ResolveTasksOutputBodyFromJson(
  Map<String, dynamic> json,
) => ResolveTasksOutputBody(
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => ResolveItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$ResolveTasksOutputBodyToJson(
  ResolveTasksOutputBody instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'results': instance.results,
};
