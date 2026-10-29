// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'delivery.dart';

part 'webhook_deliveries.g.dart';

@JsonSerializable()
class WebhookDeliveries {
  const WebhookDeliveries({required this.deliveries, this.schema});

  factory WebhookDeliveries.fromJson(Map<String, Object?> json) =>
      _$WebhookDeliveriesFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The latest delivery attempts, newest first; each retry of a delivery is an attempt of its own.
  final List<Delivery>? deliveries;

  Map<String, Object?> toJson() => _$WebhookDeliveriesToJson(this);
}
