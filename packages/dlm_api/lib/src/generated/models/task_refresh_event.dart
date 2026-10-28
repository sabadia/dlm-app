// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'refresh_attempt.dart';
import 'stream_event.dart';
import 'task_refresh_event_type.dart';

part 'task_refresh_event.g.dart';

/// A link-refresh step happened: a strategy ran or was skipped, a wait started or ended.
@JsonSerializable()
class TaskRefreshEvent {
  const TaskRefreshEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory TaskRefreshEvent.fromJson(Map<String, Object?> json) =>
      _$TaskRefreshEventFromJson(json);

  final RefreshAttempt data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final TaskRefreshEventType type;

  Map<String, Object?> toJson() => _$TaskRefreshEventToJson(this);
}
