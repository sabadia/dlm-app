// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveTasksBody _$ResolveTasksBodyFromJson(Map<String, dynamic> json) =>
    ResolveTasksBody(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ResolveTaskBody.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$ResolveTasksBodyToJson(ResolveTasksBody instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'items': instance.items};
