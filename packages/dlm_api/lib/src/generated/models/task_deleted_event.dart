// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'stream_event.dart';
import 'task.dart';
import 'task_deleted_event_type.dart';

part 'task_deleted_event.g.dart';

/// A task was deleted; data is its last state.
@JsonSerializable()
class TaskDeletedEvent {
  const TaskDeletedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory TaskDeletedEvent.fromJson(Map<String, Object?> json) =>
      _$TaskDeletedEventFromJson(json);

  final Task data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final TaskDeletedEventType type;

  Map<String, Object?> toJson() => _$TaskDeletedEventToJson(this);
}
