// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_deliveries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookDeliveries _$WebhookDeliveriesFromJson(Map<String, dynamic> json) =>
    WebhookDeliveries(
      deliveries: (json['deliveries'] as List<dynamic>?)
          ?.map((e) => Delivery.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$WebhookDeliveriesToJson(WebhookDeliveries instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'deliveries': instance.deliveries,
    };
