// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The event type; also the SSE event name.
@JsonEnum()
enum QueueDeletedEventType {
  /// Incorrect name has been replaced. Original name: `queue.deleted`.
  @JsonValue('queue.deleted')
  undefined0('queue.deleted'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const QueueDeletedEventType(this.json);

  factory QueueDeletedEventType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<QueueDeletedEventType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
