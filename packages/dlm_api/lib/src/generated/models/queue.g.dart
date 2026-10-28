// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Queue _$QueueFromJson(Map<String, dynamic> json) => Queue(
  createdAt: DateTime.parse(json['createdAt'] as String),
  id: json['id'] as String,
  isDefault: json['isDefault'] as bool,
  name: json['name'] as String,
  position: (json['position'] as num).toInt(),
  settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
  state: json['state'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$QueueToJson(Queue instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'createdAt': instance.createdAt.toIso8601String(),
  'id': instance.id,
  'isDefault': instance.isDefault,
  'name': instance.name,
  'position': instance.position,
  'settings': instance.settings,
  'state': instance.state,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
