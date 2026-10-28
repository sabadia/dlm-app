// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'status_data.dart';
import 'stream_event.dart';
import 'task_status_event_type.dart';

part 'task_status_event.g.dart';

/// A task moved to another status.
@JsonSerializable()
class TaskStatusEvent {
  const TaskStatusEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory TaskStatusEvent.fromJson(Map<String, Object?> json) =>
      _$TaskStatusEventFromJson(json);

  final StatusData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final TaskStatusEventType type;

  Map<String, Object?> toJson() => _$TaskStatusEventToJson(this);
}
