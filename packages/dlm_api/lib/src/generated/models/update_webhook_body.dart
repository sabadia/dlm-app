// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_webhook_body.g.dart';

@JsonSerializable()
class UpdateWebhookBody {
  const UpdateWebhookBody({
    this.schema,
    this.enabled,
    this.events,
    this.secret,
    this.url,
  });

  factory UpdateWebhookBody.fromJson(Map<String, Object?> json) =>
      _$UpdateWebhookBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Switch the webhook on or off.
  final bool? enabled;

  /// New event types (replaces the old list).
  final List<String>? events;

  /// New signing secret; an empty string removes it.
  final String? secret;

  /// New endpoint.
  final String? url;

  Map<String, Object?> toJson() => _$UpdateWebhookBodyToJson(this);
}
