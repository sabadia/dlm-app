// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'refresh_requested_data.dart';
import 'stream_event.dart';
import 'task_refresh_requested_event_type.dart';

part 'task_refresh_requested_event.g.dart';

/// A task's link expired and it waits for the browser extension to capture a fresh one: open pageUrl so the user can start the download again before the deadline.
@JsonSerializable()
class TaskRefreshRequestedEvent {
  const TaskRefreshRequestedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory TaskRefreshRequestedEvent.fromJson(Map<String, Object?> json) =>
      _$TaskRefreshRequestedEventFromJson(json);

  final RefreshRequestedData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final TaskRefreshRequestedEventType type;

  Map<String, Object?> toJson() => _$TaskRefreshRequestedEventToJson(this);
}
