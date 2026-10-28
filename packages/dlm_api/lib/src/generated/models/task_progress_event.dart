// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'progress_data.dart';
import 'stream_event.dart';
import 'task_progress_event_type.dart';

part 'task_progress_event.g.dart';

/// Transfer progress of a running task; coalesced per task, at most a few per second.
@JsonSerializable()
class TaskProgressEvent {
  const TaskProgressEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory TaskProgressEvent.fromJson(Map<String, Object?> json) =>
      _$TaskProgressEventFromJson(json);

  final ProgressData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final TaskProgressEventType type;

  Map<String, Object?> toJson() => _$TaskProgressEventToJson(this);
}
