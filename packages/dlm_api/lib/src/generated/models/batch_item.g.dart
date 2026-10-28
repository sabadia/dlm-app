// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchItem _$BatchItemFromJson(Map<String, dynamic> json) => BatchItem(
  ok: json['ok'] as bool,
  error: json['error'] == null
      ? null
      : Problem.fromJson(json['error'] as Map<String, dynamic>),
  id: json['id'] as String?,
  task: json['task'] == null
      ? null
      : Task.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BatchItemToJson(BatchItem instance) => <String, dynamic>{
  'error': instance.error,
  'id': instance.id,
  'ok': instance.ok,
  'task': instance.task,
};
