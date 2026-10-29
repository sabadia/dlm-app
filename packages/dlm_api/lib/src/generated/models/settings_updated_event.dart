// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'settings.dart';
import 'settings_updated_event_type.dart';
import 'stream_event.dart';

part 'settings_updated_event.g.dart';

/// The global settings changed; data is the new global layer.
@JsonSerializable()
class SettingsUpdatedEvent {
  const SettingsUpdatedEvent({
    required this.data,
    required this.id,
    required this.time,
    required this.type,
    this.queueId,
    this.taskId,
  });

  factory SettingsUpdatedEvent.fromJson(Map<String, Object?> json) =>
      _$SettingsUpdatedEventFromJson(json);

  final Settings data;

  /// Bus sequence number; the SSE id is <bootID>-<id>.
  final int id;

  /// The queue the event is about, if any.
  final String? queueId;

  /// The task the event is about, if any.
  final String? taskId;

  /// When the event was emitted (UTC).
  final DateTime time;

  /// The event type; also the SSE event name.
  final SettingsUpdatedEventType type;

  Map<String, Object?> toJson() => _$SettingsUpdatedEventToJson(this);
}
