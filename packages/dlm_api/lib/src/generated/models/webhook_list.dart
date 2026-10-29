// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'webhook.dart';

part 'webhook_list.g.dart';

@JsonSerializable()
class WebhookList {
  const WebhookList({required this.webhooks, this.schema});

  factory WebhookList.fromJson(Map<String, Object?> json) =>
      _$WebhookListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Every webhook, oldest first.
  final List<Webhook>? webhooks;

  Map<String, Object?> toJson() => _$WebhookListToJson(this);
}
