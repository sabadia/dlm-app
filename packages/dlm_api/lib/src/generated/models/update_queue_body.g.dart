// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_queue_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateQueueBody _$UpdateQueueBodyFromJson(Map<String, dynamic> json) =>
    UpdateQueueBody(
      schema: json[r'$schema'] as String?,
      name: json['name'] as String?,
      settings: json['settings'],
    );

Map<String, dynamic> _$UpdateQueueBodyToJson(UpdateQueueBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'name': instance.name,
      'settings': instance.settings,
    };
