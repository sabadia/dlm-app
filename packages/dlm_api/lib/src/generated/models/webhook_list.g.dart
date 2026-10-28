// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookList _$WebhookListFromJson(Map<String, dynamic> json) => WebhookList(
  webhooks: (json['webhooks'] as List<dynamic>?)
      ?.map((e) => Webhook.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$WebhookListToJson(WebhookList instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'webhooks': instance.webhooks,
    };
