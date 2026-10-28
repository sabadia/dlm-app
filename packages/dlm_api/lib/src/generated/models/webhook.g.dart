// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Webhook _$WebhookFromJson(Map<String, dynamic> json) => Webhook(
  createdAt: DateTime.parse(json['createdAt'] as String),
  enabled: json['enabled'] as bool,
  events: (json['events'] as List<dynamic>?)?.map((e) => e as String).toList(),
  hasSecret: json['hasSecret'] as bool,
  id: json['id'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  url: json['url'] as String,
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$WebhookToJson(Webhook instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'createdAt': instance.createdAt.toIso8601String(),
  'enabled': instance.enabled,
  'events': instance.events,
  'hasSecret': instance.hasSecret,
  'id': instance.id,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'url': instance.url,
};
