// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_webhook_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateWebhookBody _$UpdateWebhookBodyFromJson(Map<String, dynamic> json) =>
    UpdateWebhookBody(
      schema: json[r'$schema'] as String?,
      enabled: json['enabled'] as bool?,
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      secret: json['secret'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$UpdateWebhookBodyToJson(UpdateWebhookBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'enabled': instance.enabled,
      'events': instance.events,
      'secret': instance.secret,
      'url': instance.url,
    };
