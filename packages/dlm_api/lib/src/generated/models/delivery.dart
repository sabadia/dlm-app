// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'delivery.g.dart';

@JsonSerializable()
class Delivery {
  const Delivery({
    required this.attempt,
    required this.durationMs,
    required this.event,
    required this.eventId,
    required this.id,
    required this.ok,
    required this.status,
    required this.time,
    required this.willRetry,
    this.error,
  });

  factory Delivery.fromJson(Map<String, Object?> json) =>
      _$DeliveryFromJson(json);

  final int attempt;
  final int durationMs;
  final String? error;

  /// The event type, or webhook.test for a test delivery.
  final String event;
  final int eventId;
  final int id;
  final bool ok;
  final int status;
  final DateTime time;
  final bool willRetry;

  Map<String, Object?> toJson() => _$DeliveryToJson(this);
}
