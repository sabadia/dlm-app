// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_webhook_body.g.dart';

@JsonSerializable()
class CreateWebhookBody {
  const CreateWebhookBody({
    required this.events,
    required this.url,
    this.schema,
    this.disabled,
    this.secret,
  });

  factory CreateWebhookBody.fromJson(Map<String, Object?> json) =>
      _$CreateWebhookBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Create the webhook switched off.
  final bool? disabled;

  /// Event types to deliver, such as task.status or queue.completed.
  final List<String>? events;

  /// Signs each body: the X-DLM-Signature header is sha256= and the hex HMAC-SHA256. Never returned.
  final String? secret;

  /// The http or https endpoint that receives a POST per event.
  final String url;

  Map<String, Object?> toJson() => _$CreateWebhookBodyToJson(this);
}
