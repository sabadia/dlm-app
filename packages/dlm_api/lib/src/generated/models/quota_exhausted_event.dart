// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'quota_data.dart';
import 'quota_exhausted_event_type.dart';
import 'stream_event.dart';

part 'quota_exhausted_event.g.dart';

/// A global or queue byte quota was used up.
@JsonSerializable()
class QuotaExhaustedEvent {
  const QuotaExhaustedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory QuotaExhaustedEvent.fromJson(Map<String, Object?> json) =>
      _$QuotaExhaustedEventFromJson(json);

  final QuotaData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final QuotaExhaustedEventType type;

  Map<String, Object?> toJson() => _$QuotaExhaustedEventToJson(this);
}
