// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuplicateHint _$DuplicateHintFromJson(Map<String, dynamic> json) =>
    DuplicateHint(
      name: json['name'] as String,
      status: json['status'] as String,
      taskId: json['taskId'] as String,
      archived: json['archived'] as bool?,
    );

Map<String, dynamic> _$DuplicateHintToJson(DuplicateHint instance) =>
    <String, dynamic>{
      'archived': instance.archived,
      'name': instance.name,
      'status': instance.status,
      'taskId': instance.taskId,
    };
