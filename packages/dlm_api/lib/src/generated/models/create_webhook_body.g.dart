// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_webhook_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateWebhookBody _$CreateWebhookBodyFromJson(Map<String, dynamic> json) =>
    CreateWebhookBody(
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      url: json['url'] as String,
      schema: json[r'$schema'] as String?,
      disabled: json['disabled'] as bool?,
      secret: json['secret'] as String?,
    );

Map<String, dynamic> _$CreateWebhookBodyToJson(CreateWebhookBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'disabled': instance.disabled,
      'events': instance.events,
      'secret': instance.secret,
      'url': instance.url,
    };
