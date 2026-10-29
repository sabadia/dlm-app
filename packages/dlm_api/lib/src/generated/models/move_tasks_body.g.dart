// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_tasks_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoveTasksBody _$MoveTasksBodyFromJson(Map<String, dynamic> json) =>
    MoveTasksBody(
      queueId: json['queueId'] as String,
      schema: json[r'$schema'] as String?,
      filter: json['filter'] == null
          ? null
          : TaskSelectorFilter.fromJson(json['filter'] as Map<String, dynamic>),
      ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MoveTasksBodyToJson(MoveTasksBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'filter': instance.filter,
      'ids': instance.ids,
      'queueId': instance.queueId,
    };
