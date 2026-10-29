// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'speed_data.dart';
import 'stream_event.dart';
import 'system_speed_event_type.dart';

part 'system_speed_event.g.dart';

/// The transfer speed of the whole daemon: once a second while anything moves, and once more (zeros) when it stops.
@JsonSerializable()
class SystemSpeedEvent {
  const SystemSpeedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory SystemSpeedEvent.fromJson(Map<String, Object?> json) =>
      _$SystemSpeedEventFromJson(json);

  final SpeedData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final SystemSpeedEventType type;

  Map<String, Object?> toJson() => _$SystemSpeedEventToJson(this);
}
