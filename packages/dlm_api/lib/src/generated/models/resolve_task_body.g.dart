// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_task_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveTaskBody _$ResolveTaskBodyFromJson(Map<String, dynamic> json) =>
    ResolveTaskBody(
      schema: json[r'$schema'] as String?,
      queueId: json['queueId'] as String?,
      settings: json['settings'] == null
          ? null
          : Settings.fromJson(json['settings'] as Map<String, dynamic>),
      source: json['source'] == null
          ? null
          : SourceInput.fromJson(json['source'] as Map<String, dynamic>),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ResolveTaskBodyToJson(ResolveTaskBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'queueId': instance.queueId,
      'settings': instance.settings,
      'source': instance.source,
      'url': instance.url,
    };
