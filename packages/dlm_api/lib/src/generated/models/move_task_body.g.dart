// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_task_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoveTaskBody _$MoveTaskBodyFromJson(Map<String, dynamic> json) => MoveTaskBody(
  queueId: json['queueId'] as String,
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$MoveTaskBodyToJson(MoveTaskBody instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'queueId': instance.queueId};
