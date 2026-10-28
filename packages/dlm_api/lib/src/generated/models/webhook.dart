// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'webhook.g.dart';

@JsonSerializable()
class Webhook {
  const Webhook({
    required this.createdAt,
    required this.enabled,
    required this.events,
    required this.hasSecret,
    required this.id,
    required this.updatedAt,
    required this.url,
    this.schema,
  });

  factory Webhook.fromJson(Map<String, Object?> json) =>
      _$WebhookFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final DateTime createdAt;
  final bool enabled;
  final List<String>? events;
  final bool hasSecret;
  final String id;
  final DateTime updatedAt;
  final String url;

  Map<String, Object?> toJson() => _$WebhookToJson(this);
}
