// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_queue_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateQueueBody _$CreateQueueBodyFromJson(Map<String, dynamic> json) =>
    CreateQueueBody(
      name: json['name'] as String,
      schema: json[r'$schema'] as String?,
      settings: json['settings'] == null
          ? null
          : Settings.fromJson(json['settings'] as Map<String, dynamic>),
      state: json['state'] == null
          ? null
          : CreateQueueBodyState.fromJson(json['state'] as String),
    );

Map<String, dynamic> _$CreateQueueBodyToJson(CreateQueueBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'name': instance.name,
      'settings': instance.settings,
      'state': _$CreateQueueBodyStateEnumMap[instance.state],
    };

const _$CreateQueueBodyStateEnumMap = {
  CreateQueueBodyState.running: 'running',
  CreateQueueBodyState.stopped: 'stopped',
  CreateQueueBodyState.$unknown: r'$unknown',
};
