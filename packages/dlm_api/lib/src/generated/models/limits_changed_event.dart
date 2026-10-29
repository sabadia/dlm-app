// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'limits_changed_data.dart';
import 'limits_changed_event_type.dart';
import 'stream_event.dart';

part 'limits_changed_event.g.dart';

/// The temporary global speed override was set, cleared or ran out; data is the limit now in force.
@JsonSerializable()
class LimitsChangedEvent {
  const LimitsChangedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory LimitsChangedEvent.fromJson(Map<String, Object?> json) =>
      _$LimitsChangedEventFromJson(json);

  final LimitsChangedData data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final LimitsChangedEventType type;

  Map<String, Object?> toJson() => _$LimitsChangedEventToJson(this);
}
