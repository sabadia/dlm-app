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
    );

Map<String, dynamic> _$DuplicateHintToJson(DuplicateHint instance) =>
    <String, dynamic>{
      'name': instance.name,
      'status': instance.status,
      'taskId': instance.taskId,
    };
