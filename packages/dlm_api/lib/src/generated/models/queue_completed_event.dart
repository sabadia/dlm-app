// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'queue_completed_data.dart';
import 'queue_completed_event_type.dart';
import 'stream_event.dart';

part 'queue_completed_event.g.dart';

/// A queue with an onQueueComplete action ran out of work; the action runs at executeAt unless cancelled.
@JsonSerializable()
class QueueCompletedEvent {
  const QueueCompletedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory QueueCompletedEvent.fromJson(Map<String, Object?> json) =>
      _$QueueCompletedEventFromJson(json);

  final QueueCompletedData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final QueueCompletedEventType type;

  Map<String, Object?> toJson() => _$QueueCompletedEventToJson(this);
}
