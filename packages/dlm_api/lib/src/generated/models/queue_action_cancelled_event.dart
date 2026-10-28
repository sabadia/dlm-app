// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action_cancelled_data.dart';
import 'queue_action_cancelled_event_type.dart';
import 'stream_event.dart';

part 'queue_action_cancelled_event.g.dart';

/// A pending post-queue action was cancelled (new work, queue stopped or deleted, settings changed).
@JsonSerializable()
class QueueActionCancelledEvent {
  const QueueActionCancelledEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory QueueActionCancelledEvent.fromJson(Map<String, Object?> json) =>
      _$QueueActionCancelledEventFromJson(json);

  final ActionCancelledData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final QueueActionCancelledEventType type;

  Map<String, Object?> toJson() => _$QueueActionCancelledEventToJson(this);
}
